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
    actor User as ユーザー
    User ->>+ Local_Camera: ローカルカメラを開く
    Local_Camera ->>+ PhotoData: 痕跡データをロード
    PhotoData -->>- Local_Camera: 痕跡データを返す
    Local_Camera ->> Local_Camera: サークルチャートと痕跡枚数を表示
    User ->>+ Local_Camera: 痕跡を撮影する
    Local_Camera ->>+ ImagePicker: カメラを起動
    ImagePicker -->>- Local_Camera: 撮影画像を取得
    Local_Camera ->>+ ImageGallerySaver: 撮影画像をギャラリーに保存
    ImageGallerySaver -->>- Local_Camera: 保存結果を返す
    Local_Camera ->>+ Geolocator: 現在の位置情報を取得
    Geolocator -->>- Local_Camera: 位置情報を返す
    Local_Camera ->>+ AnimalTypeMemoWizard: メモと痕跡の種類を選択
    AnimalTypeMemoWizard -->>- Local_Camera: メモと痕跡のデータを返す
    Local_Camera ->>+ File: 痕跡情報をローカルに保存
    File -->>- Local_Camera: 痕跡情報を保存完了
    User ->>+ Local_Camera: 画像をアップロード
    Local_Camera ->>+ Connectivity: ネットワーク接続を確認
    Connectivity -->>- Local_Camera: 接続確認結果を返す
    Local_Camera ->>+ Firebase Storage: 画像をFirebaseにアップロード
    Firebase Storage -->>- Local_Camera: 画像のURLを取得
    Local_Camera ->>+ Firestore: 痕跡データをFirestoreに保存
    Firestore -->>- Local_Camera: 保存完了
    Local_Camera -->> User: 処理完了メッセージを表示

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
