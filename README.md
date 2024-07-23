<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/8e6a0fec-bf99-4371-9bfd-a29702952058">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/f8973d14-a67b-4cc9-ad7e-f648edeae5ba">
</picture>

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

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            ProductHuntBadge(slug: "stepup")
                .environment(\.colorScheme, .light)

            ProductHuntBadge(id: 471947)
                .environment(\.colorScheme, .dark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.embedBackground)
        .ignoresSafeArea()
    }
}
```
