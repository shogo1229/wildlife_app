# wildlife_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# メインページ の表示

```mermaid
sequenceDiagram
autonumber
actor User
User ->>+ MainPage: MainPageへ遷移
MainPage ->>+ FireBase: ユーザー情報リクエスト
FireBase-->>- MainPage: ユーザー情報レスポンス
MainPage ->>+ GoogleMAP API: 地図情報リクエスト
GoogleMAP API-->>- MainPage: 地図情報レスポンス
MainPage ->>+ FireBase: 痕跡位置情報リクエスト
FireBase -->>- MainPage: 痕跡地位情報レスポンス
MainPage -->- User:MainPageを表示
```

# 痕跡 MAP の表示

```mermaid
sequenceDiagram
autonumber
actor User
User ->>+ MapPage: MapPageへ遷移
MapPage ->>+ GoogleMAP API: 地図情報リクエスト
GoogleMAP API-->>- MapPage: 地図情報レスポンス
MapPage ->>+ FireBase: 痕跡位置情報リクエスト
FireBase -->>- MapPage: 痕跡地位情報レスポンス
MapPage -->- User:MapPageを表示
```

# 痕跡投稿画面の表示

```mermaid
sequenceDiagram
autonumber
actor User
User ->>+ PhotoPage: PhotoPageへ遷移
PhotoPage -->- User:PhotoPageを表示
User ->>+ PhotoPage: 痕跡の写真を撮影
PhotoPage ->>+ FireBase: FireBaseへの接続リクエスト
FireBase -->>- PhotoPage: FireBaseへ接続状況を返却
opt FireBaseに接続可能
PhotoPage ->>+ PhotoPage(画像キュー):リクエスト
PhotoPage(画像キュー) ->>+ PhotoPage:レスポンス
PhotoPage ->>+ FireBase(Image): 画像をアップロード
FireBase(Image) -->- PhotoPage: アップロード結果レスポンス
PhotoPage ->>+ FireBase(User): 痕跡ptを加算
FireBase(User) -->- PhotoPage: 取得した痕跡ptを通知
end

opt FireBaseに接続不可
PhotoPage ->>+ PhotoPage(画像キュー):画像保存
PhotoPage(画像キュー)-->>- PhotoPage :保存結果レスポンス
end

PhotoPage -->>- User: 投稿処理完了
```

# 痕跡投稿画面の表示

```mermaid
sequenceDiagram
autonumber
actor User
User ->>+ RankPage: RankPageへ遷移
RankPage ->>+ FireBase(User):ユーザ情報リクエスト
FireBase(User)　-->>-RankPage:ユーザ情報レスポンス
RankPage ->>+ FireBase(Rank):ランキング情報リクエスト
FireBase(Rank)-->>-RankPage:ランキング情報レスポンス
RankPage -->- User:RankPageを表示

```

# ユーザープロフィール画面の表示

```mermaid
sequenceDiagram
autonumber
actor User
User ->>+ ProfilePage: ProfilePageへ遷移
ProfilePage ->>+ FireBase(User):ユーザ情報リクエスト
FireBase(User)　-->>-ProfilePage:ユーザ情報レスポンス
ProfilePage ->>+ FireBase(Rank):ランキング情報リクエスト
FireBase(Rank)-->>-ProfilePage:ランキング情報レスポンス
ProfilePage -->- User:RankPageを表示

```
