# xl-oauth

OAuth 1.0 クライアントライブラリ for xyzzy


## Install
- NetInstallerをよりインストール
  下記のURLのパッケージリストを登録し、パッケージ`*scrap*`よりインストールして下さい。
  http://youz.github.com/xyzzy/package.l

- 手動インストール
  oauth.l を`*load-path*`に配置してください。

※依存ライブラリ[xml-http-request](http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm)を別途インストールしておく必要があります。


## Usage

- oauth:get-access-token
  (consumer-key consumer-secret request-token-url authorize-url access-token-url)
    => access-token, access-token-secret

  以下の一連の認証処理を実行し、取得したアクセストークン(oauth_token, oauth_token_secret)を多値で返します。
    1. リクエストトークンの要求
    2. 認証用ページ表示 (システム標準のWEBブラウザを起動して表示します)
    3. PIN (oauth_verifier) 入力
    4. アクセストークン取得

  引数
    * cosumer-key - サービスプロバイダより発行されたConsumer Key
    * consumer-secret - サービスプロバイダより発行されたConsumer Secret
    * request-token-url - リクエストトークン発行用URL
    * authorize-url -- サービスプロバイダの認証用URL
    * access-token-url -- アクセストークン発行用URL

  twitterよりアクセストークンを取得し、ファイルに保存する例

        (multiple-value-bind (token token-secret)
            (get-access-token *my-app-key* *my-app-secret*
                              "http://api.twitter.com/oauth/request_token"
                              "http://api.twitter.com/oauth/authorize"
                              "http://api.twitter.com/oauth/access_token")
          (with-open-file (str *token-file* :direction :output)
            (format str "~A~%~A" token token-secret)))

- oauth:auth-header
  (credential method apiurl params)
  => header-string

  サービスプロバイダのAPIを利用する際に必要なOAuth認証ヘッダを生成します。

    引数
      * credential
        コンシューマキー, コンシューマシークレット, アクセストークン, アクセストークンのplist。
        キーシンボルはそれぞれ :consumer-key, :consumer-secret, :token, :token-secret です。
      * method - HTTPメソッドをシンボルか文字列で指定します。
      * apiurl - APIのURL
      * params - APIに渡すパラメータをplistで指定します。

  twitterの[help/test API](https://dev.twitter.com/docs/api/1/get/help/test)にリクエストを投げる例

        (let* ((url "http://api.twitter.com/1/help/test.json")
               (cred (list :consumer-key *my-app-key*
                           :consumer-secret *my-app--secret*
                           :token *token*
                           :token-secret *token-secret*))
               (auth (oauth:auth-header cred 'get url nil)))
          (xhr:xhr-get url :headers `(:Authorization ,auth)
                       :key #'xhr:xhr-response-text))


## Author
Yousuke Ushiki (<citrus.yubeshi@gmail.com>)

[@Yubeshi](http://twitter.com/Yubeshi/)

## Copyright
MIT License を適用しています。

