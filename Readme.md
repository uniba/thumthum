動かす準備

    $ bundle install --path vendor/bundle

認証

    $ bundle exec tumblr

上のコマンドを実行するとOAuth Consumer keyとOAuth Consumer secretを入力することが求められる。
入力するとURLが表示されるのでそこにアクセスすると
`http://hoge.fuga/callback?oauth_token=*******************************&oauth_verifier=******************************#_=_`
のようなURLにリダイレクトされる。oauth_verifierのvalueをコピペして、ターミナルに入力する。
認証に成功したらirbが実行されるので`exit`する。

`~/.tumblr`に認証情報を記録したファイルが作成される。


```

$ bundle exec tumblr
Register an application at: http://www.tumblr.com/oauth/apps
OAuth Consumer key: **************************************************
OAuth Consumer secret: **************************************************

http://www.tumblr.com/oauth/authorize?oauth_token=Nu12eUGBjUEP3WBC7ocBVTVLfs47SKyrdRTxA9zRMIPP4Bvv4g
Post-redirect, copy the oauth_verifier
OAuth Verifier: ******************************

        .                                 .o8       oooo
      .o8                                "888       `888
    .o888oo oooo  oooo  ooo. .oo.  .oo.   888oooo.   888  oooo d8b
      888   `888  `888  `888P"Y88bP"Y88b  d88' `88b  888  `888""8P
      888    888   888   888   888   888  888   888  888   888
      888 .  888   888   888   888   888  888   888  888   888    .o.
      "888"  `V88V"V8P' o888o o888o o888o `Y8bod8P' o888o d888b   Y8P

irb(main):001:0> ENV['IRBRC']
=> nil
irb(main):002:0> exit

```

jsonファイル用意

`json`フォルダに投稿したいtumblrのホスト名のディレクトリを作成する。(`http://unibaapitest.tumblr.com` の場合 `unibaapitest.tumblr.com`)

jsonのファイル名はコマンドラインで指定するので、適当な名前でjsonファイルを作ってください。
jsonのパラメータは https://www.tumblr.com/docs/en/api/v2#posting を参考にしてください。

画像を投稿する場合は`"data": ["photo/cat.jpg", "photo/cat.png", "photo/earth.gif"]`のように  
ホスト名のディレクトリからの相対パスを指定してください。


実行

投稿

    ruby app.rb -t text -u http://unibaapitest.tumblr.com -j text.json

| option   | description                                                        | sample       | require |
| --------- | ----------------------------------------------------------------- | ------------ | ------- |
| -t or --type | text または photo | -t text | yes |
| -u or --url | 投稿したいtumblrのurl | -u http://unibaapitest.tumblr.com/ | yes |
| -j or --json | 使用するjsonファイル名。「jsonファイル用意」で作成したものを指定する。 | -j test.json | yes |
| -n or --number | 投稿する件数(指定しない時は 1) | -n 20 | no |

削除

    ruby app.rb --delete -u http://unibaapitest.tumblr.com

| option | description | sample | require |
| ------ | ------------ | ------ | -------- |
| -u or --url | 投稿したいtumblrのurl | -u http://unibaapitest.tumblr.com/ | yes |
