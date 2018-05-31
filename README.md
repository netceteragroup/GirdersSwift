# Girders for Swift
Framework for building iOS applications, developed at Netcetera.

[![Build Status](https://img.shields.io/travis/netceteragroup/GirdersSwift/master.svg?style=flat-square)](https://travis-ci.org/netceteragroup/GirdersSwift)
[![Coverage Status](https://coveralls.io/repos/github/netceteragroup/GirdersSwift/badge.svg?branch=master)](https://coveralls.io/github/netceteragroup/GirdersSwift?branch=master)

## What is Girders? ##

If you ask Google, girder is a large iron or steel beam or compound structure used for building bridges and the framework of large buildings. Inspired by this, Girders is the standard name for most of the frameworks we develop at Netcetera. 

GirdersSwift is a new framework, written in Swift, that has several modules that you might find useful in your apps:
- networking
- serialization
- dependency injection
- storage
- configuration

We plan to add several new modules in the future, all build in the open. Feel free to get in touch with ideas extending the framework.

## Core philosophy ##

*"A good architect maximizes the number of decisions not made"* — Robert Martin.

The idea of the framework is to be as small as possible, but at the same time, as independent as possible from other frameworks. On one hand, we don't want to re-invent the wheel, when there are a lot of good frameworks for certain common tasks in iOS development. On the other, we don't want to heavily depend on third-party frameworks. That's why we are relying on protocols a lot. 

This framework doesn't intend to force you on an app architecture, or async programming abstraction. You are free to choose whether you will use completionHandlers, futures/promises or RX extensions. This decision is delegated to the project.

One of the goals of the framework is to provide enough extension points to extend its functionalities, without changing the underlying implementation. Some form of the decorator pattern is used throughout the framework.

## Modules ##

### Networking ###

When you think of what a networking framework should do, the job is pretty simple:
1. create a request
2. send the request
3. handle the response

The first part, the creation of the request seems to be the most complicated part. There are a lot of different requests - with different request headers, with SSL credentials, with basic authorisation, different HTTP methods (GET, POST and 6 more), different parameters, body and so on. A good networking library should provide an easy and robust way of creating all these different kinds of requests.

The second part is probably the simplest part - making a wrapper to the system libraries that do the actual job of sending the request through the network and receiving the response. Here is the place where you will use the NSURLSession or NSURLConnection.

After the request finishes, its response should be properly handled - here you check whether the request is successful. If it's successful then based on the Content-Type properly handle it - maybe parse a json/xml response and based on it maybe provide some already created model object/struct back to the caller. Here's the place where you can attach the appropriate response serializers.

We have our own types for Request, Response and Error. At the core of our networking library is our HTTP protocol. We provide one implementation of it with Apple's NSURLSession.

Our core method here is:

```swift
func executeRequest<T>(request: Request,
                       completionHandler: @escaping (Result<Response<T>, Error?>) -> Void)
```

#### Customising the request ####

Our Request type is immutable - when the request is created and all of the properties are filled with data, those values should not change anymore. We are working in a multi threaded environment, so introducing mutability will bring more complexity and bugs.

There's a mutable version of the Request, used by our RequestGenerator protocol, which has the task to build and customise the request. The customisation of the request is done by providing set of pure functions, that take a request, add additional info (e.g. headers) and return a modified copy of the request.

The beauty of this approach is that you can easily combine the provided functions to create different types of requests, without modifying the implementation. Also, you can define your own functions to decorate the request. You can build the requests with the forward pipe operator, for better clarity.

Override the generateRequest(withMethod:) in your own RequestGenerator to customise requests. For example, if you want to add JSON support to a request, you can do the following:

```swift
public func generateRequest(withMethod method: HTTPMethod) -> MutableRequest {
    return request(withMethod: method) |> withJsonSupport
}
```

If you want to add SSL credentials and basic authentication, later on, the only change you need to do is:

```swift
public func generateRequest(withMethod method: HTTPMethod) -> MutableRequest {
    return request(withMethod: method) |> withJsonSupport |> withSSLCredentials |> withBasicAuth
}
```

You can create as many request generators as you need and use the functions to build the different types of requests in your app. All of the request generators can combine the same functions to create different types of requests, without duplicating anything.

There are several convenience initializer methods to create a request, depending on the level of customisation you want to have. Here's the most flexible option.

```swift
public init(URL: URL,
            method: HTTPMethod,
            parameters: [String: Any],
            queryParameters: [String: Any] = [:],
            requestGenerator: RequestGenerator)
```

#### Endpoints ####

Working directly with URLs can be a tedious and error prone job. That's why we provide another abstraction - ServiceEndpoint, inspired by the Moya framework (https://github.com/Moya/Moya). The goal of the service endpoints is to enable creation of REST service endpoint URLs in a type safe manner. 

Endpoints are protocols as well. The implementation can be any type, such as enum, struct or class. Endpoints use request generators under the hood, so you can define your custom request generators per endpoint, or even per URL or type of method.

Here's an example of an endpoint:

```swift
enum PaymentEndpoint {
    case RechargeCredit
    case CheckCardStatus
}

struct SecureRequestGenerator : RequestGenerator {
    func generateRequest(method: HTTPMethod) -> MutableRequest {
        return request(withMethod: method) |> withBasicAuth
    }
}

extension PaymentEndpoint : ServiceEndpoint {
    var baseURL: NSURL {
        get {
            return NSURL(string: "paymentBaseUrl")!
        }
    }

    var method: HTTPMethod {
        get {
            return .POST
        }
    }
     
    var path: String {
        if self == RechargeCredit {
            return "/rechargeCredit/"
        } else {
            return "/checkCardStatus/"
        }
    }

    var requestGenerator: RequestGenerator {
        get {
            return SecureRequestGenerator()
        }
    }
     
    var parameters: [String : AnyObject] {
        get {
            return ["token" : "someToken"]
        }
    }
}
```

After this setup is done, the users of the networking code will only need to specify which endpoint they want to call when creating the request.

```swift
let rechargeCredit = PaymentEndpoint.RechargeCredit
let request = Request(endpoint: rechargeCredit)
```

When using enum, you can use associated values to provide parameters to the endpoint. For example:

```swift
enum AccountEndpoint {
    case Login(String, String)
    case CreateAccount(String, String, String)
}

let createAccount = AccountEndpoint.CreateAccount(name, email, password)
let request = Request(endpoint: createAccount)
```

#### Handling the response ####

In the completion handler of our executeRequest method, we are using the Result<T, Error> enumeration, which is used a lot nowadays in the iOS SDKs.

```swift
public enum Result<T, NSError> {
    case Success(T)
    case Failure(Error?)
}
```

If the request is successful, the result is of type Response<T>. This is our custom struct containing all the neccessary things expected from a response, such as statusCode, body, bodyObject, responseHeaders and url. If the request is failing, we are returning error of the Error protocol. We also provide a ResponseError enum, implementing the common error status codes.

To handle the response, you can define your own response handlers, by implementing the ResponseHandler protocol. This allows you to attach additional logic to the response handling flow, without modifying the internal implementation.

There is already a JSON handler, that can return a dictionary with the parsed data. You can define your own parsing logic and custom objects, by implementing the ResponseHandler protocol. Use of Apple's Codable is still not used, but it's planned for the future.

Here's an example of the handlers in action.

```swift
typealias ResultHandler = ((Result<Response<[String : Any]>, Error?>) -> Void)
typealias ErrorHandler = ((Error?) -> Void)

func booleanHandler(result: @escaping (Bool) -> Void,
                    error: @escaping (Error?) -> Void) -> ResultHandler {
    let handler: ResultHandler = { requestResult in
        switch requestResult {
        case .Success(_):
            result(true)
        case .Failure(let requestError):
            error(requestError)
        }
    }
    return handler
}

func register(withRequest request: RegisterRequest,
                  result: @escaping (Bool) -> Void,
                  error: @escaping (Error?) -> Void) {
    let registerRequest = self.request(forApiKey: .Users,
                                       parameters: request.toParameters(),
                                       readOnly: false)
        httpClient.executeRequest(request: registerRequest,
                                  completionHandler: booleanHandler(result: result,
                                              error: error))
}
```

### Error handling ###

You can create your own error handlers to abstract away common error handling logic. For example, let's say that your app acceses the REST API through a token that can expire. In this case, we want to try to refresh the token, by silently loging in the user. Here's how we can do this with our error handlers.

```swift
func standardErrorHandler(_ error: @escaping ErrorHandler) -> ErrorHandler {
    let handler: ErrorHandler = { anError in
        guard let responseError = anError as? ResponseError else {
            error(anError)
            return
        }
        
        if responseError == .Unauthorized {
            autoLogin()
        } else {
            error(anError)
        }
    }
    return handler
}
```

### Third party extensions ###

#### PromiseKit ####

If you like working with promises, you can use our extension of the HTTP implementation for PromiseKit.

```swift
func executeRequestAsync<T>(request: Request) -> Promise<Response<T>> {
        return Promise { seal in
            executeRequest(request: request,
                           completionHandler: { (result: Result<Response<T>, Error?>) in
                switch result {
                case .Failure(let error):
                    seal.reject(error!)
                case .Success(let data):
                    seal.fulfill(data)
                }
            })
        }
}
```

You can create similar extensions for any async programming abstraction you need. RXSwift will be added soon.

### Configuration ###

Usually, when developing apps that talk to a REST service, we need to support several environments, such as development, staging and production. With our Configuration class, you can support such environments by providing different plist files. For production, the file should be named Configuration.plist and for an environment, Configuration-env.plist. 

When the app is running in production mode, only the Configuration file is used. Otherwise, the two configurations are merged, where the Configuration-env file has bigger priority.

The Configuration is available as a Singleton, and getting a value from it is pretty straightforward.

```swift
let apiURL = Configuration.sharedInstance[Constants.APIURLKey] as? String
```
### Secure Storage ###

There's a SecureStorage protocol, that defines methods for saving and retrieving data to a secure storage. This protocol is implemented by the KeychainStorage class, that uses another open source framework, KeychainAccess (https://github.com/kishikawakatsumi/KeychainAccess).

Example usage:

```swift
KeychainStorage.shared.save(string: username, forKey: Constants.Username)
let username = KeychainStorage.shared.string(forKey: Constants.Username)
```

### Utilities ###

#### Logging ####

There's a LogProtocol, which enables you to log at different levels, such as:
- verbose
- debug
- info
- warning
- error
- fatal

An implementation is provided with another open sourced logger, SwiftyBeaver (https://github.com/SwiftyBeaver/SwiftyBeaver). You can control the log level for different environments by setting the logLevel value in the Configuration.plist file.

#### Translation ####

If you need to support many languages, but you want to share the texts with the Android app, we have defined our own XML format, that we call trema. There's a trema.rb script in the repo, that converts a trema file to Apple's .strings format. Here's how our trema files look like:

```
<trema masterLang="de"
       noNamespaceSchemaLocation="http://software.group.nca/trema/schema/trema-1.0.xsd">
  <text key="app_name">
    <context/>
    <value lang="de" status="translated">Your DE App Name</value>
    <value lang="en" status="translated">Your EN App Name</value>
    <value lang="fr" status="translated">Your FR App Name</value>
    <value lang="it" status="translated">Your IT App Name</value>
  </text>
</trema>
```

The translations are referenced by key, using the translate function.

```swift
struct Texts {
    static let AppName = translate("app_name")
}
```

#### Date String utils ####

There are utils for converting Date to String and vice versa. Converting to and parsing dates from RFC822 and RFC3339 are supported.

### Dependency Injection ###

Girders Swift contains an Inversion of Control container that can facilitate the process of Dependency Injection. Using dependency injection improves testability, makes the components more loosly coupled and makes it easy to switch implementations.

In order to implement dependency injection, every "service" that needs to be injected, should be first defined as a protocol (a contract) that the other classes will consume. For example:

```swift
protocol SomeServiceProtocol {
    func someMethod() -> String
}
```

The implementation class would look something like this:

```swift
class SomeService: SomeServiceProtocol {
    func someMethod() -> String {
        return UUID().uuidString
    }
}
```

Instances of **SomeService** can be created every time they are needed, or they can be created only once (aka using the Singleton pattern).

In order to use the Singleton pattern the protocol and the factory method need to be registered in the **Container** like so:

```swift
Container.addSingleton { () -> SomeServiceProtocol in
    return SomeService()
}
```

If a new instance should be created every time, use:

```swift
Container.addPerRequest { () -> SomeServiceProtocol in
    return SomeService()
}
```

In order to resolve the an instance of some protocol use the **resolve** method.

```swift
let resolvedInstance: SomeServiceProtocol = Container.resolve()
```

In reality there can be "services" that are use methods from other services. To resolve the dependencies, lazy properties should be used:

```swift
class SomeOtherService {
    lazy var someService: SomeServiceProtocol = Container.resolve()

    func otherServiceMethod() {
        ...
        let someValue = someService.someMethod()
        ...
    }
}
```

Now the implementation of SomeServiceProtocol can be switched at any time. The developer can even register mock implementations when writing unit tests.
With this approach you can create interconnected services, service cascades, etc. You can use this also to inject services in your Views or ViewControllers.

**NOTE: Although this Container allows you to create circular references, that doesn't mean that you should. Be aware of creating circular references and introducing memory leaks to your applications.**

The registrations of protocols and factory methods should be done in the application's AppDelegate.

### Areas for improvement ###

- Add more unit tests
- Improve documentation
- Add methods for downloading large files
- Extend the Configuration class
- Add RXSwift support
- Add XML support
- Add a persistence layer
- And a lot more.

