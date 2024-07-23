<p align="center">
  <img width="251" alt="IMG_5219" src="https://github.com/user-attachments/assets/357da7ef-89d8-4bd5-b494-29e5d6bebd44">
  <img width="251" alt="IMG_5220" src="https://github.com/user-attachments/assets/873d3016-0817-4584-8eda-cc93aadcbd7a">
</p>

## Main Features

- **Dark & Light mode** support
- Synced with **Product Hunt API**
- Cached in **UserDefaults**
- Refreshed when app becomes active

## References
Here are some iOS and macOS apps using Product Hunt Badge, give it a try!

[<img src="https://github.com/user-attachments/assets/c263ea4e-2403-4e2f-9f7b-ab721bfa4824" width="64" height="64">](https://apps.apple.com/app/id6502121777)

[Add your app](https://github.com/sponsors/appcraftconsulting/sponsorships?tier_id=417653)

# Documentation

## Authentication

In order to refresh upvotes count, you need to provide authentication information so the badge can communicate with Product Hunt API.

You can generate tokens by signing in to Product Hunt, then going to [API Dashboard](https://www.producthunt.com/v2/oauth/applications).

Application or Developer Token? Here is what Product Hunt API Documentation mentions:
> But… i just wanted to run a simple script?
> - The oauth2 flow is a bit of a overkill if you just want to run a few scripts
> - We provide a developer_token (does not expire, linked to your account) in the API dashboard

#### Developer Token
```swift
@main
struct SideProjectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .productHuntCredentials(.developerToken("{TOKEN}"))
        }
    }
}
```

#### Application Credentials
```swift
@main
struct SideProjectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .productHuntCredentials(.application(
                    clientId: "API_KEY",
                    clientSecret: "API_SECRET"
                ))
        }
    }
}
```

> [!TIP]
> Inject your Product Hunt credentials at your root view so it can be accessible wherever you embed the badge in your app.

## Usage

You can either identify your Product Hunt post by its slug or id:
```swift
// Product Hunt Badge using its slug (String)
ProductHuntBadge(slug: "stepup")
// Product Hunt Badge using its id (Int)
ProductHuntBadge(id: 471947)
```

Also, keep in mind you can override system appearance using `colorScheme` environment value:
```swift
ProductHuntBadge(slug: "stepup")
    .environment(\.colorScheme, .dark)
```
