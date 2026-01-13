# ORAS × Harbor デモ（Client）

このフォルダは、**ORAS を使って任意のファイルを OCI artifact として Harbor に push / pull する最小構成のデモ**です。
必要なのは **client 側のみ**で、Harbor は **すでに起動していて接続可能**であることを前提とします。

---

## 前提条件（Prerequisites）

* Harbor に **事前に Project が作成されていること**
  （UI または API で作成してください）

* ORAS CLI がインストールされていること
  * ubuntu22 OS:
```bash
# 作業用ディレクトリ
cd /tmp
# 最新版の ORAS をダウンロード（Linux amd64）
curl -LO https://github.com/oras-project/oras/releases/latest/download/oras_$(uname -s | tr A-Z a-z)_amd64.tar.gz
# 展開
tar -xzf oras_linux_amd64.tar.gz
# 実行ファイルを PATH に配置
sudo mv oras /usr/local/bin/
# 実行確認
oras version
```


* 本デモで使用する **artifact の参照名**は、以下の形式で統一されています。

```
${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_REPO}:${HARBOR_TAG}
```

---

## デモ用ファイル（Demo Files）

`client/demo-artifact/` には、**1つの artifact として push されるファイル群**が入っています。

* `hello.txt`
* `metadata.json`
* `README.md`

このフォルダにファイルを追加すると、`oras push` 実行時に **すべてまとめて 1 つの artifact として** Harbor に保存されます。

---

## クイックスタート（Quick Start）

```bash
cd client

export HARBOR_REGISTRY=harbor.local
export HARBOR_PROJECT=demo
export HARBOR_REPO=oras-sample
export HARBOR_TAG=v1
export HARBOR_USERNAME=admin
export HARBOR_PASSWORD=Harbor12345

./scripts/00_check.sh    # 環境変数・コマンド・デモファイルの確認
./scripts/10_login.sh    # 環境変数の認証情報を使って oras login
./scripts/20_push.sh     # demo-artifact を 1 つの OCI artifact として push
./scripts/30_pull.sh     # pull して ./out/ に展開
./scripts/40_verify.sh   # pull したファイルが元と一致するか確認
```

### 補足

* `out/` ディレクトリは push の前に毎回クリーンアップされます
* pull 時には取得したファイル一覧を表示し、artifact の中身が分かるようになっています

---

## 期待される出力例（抜粋）

### Push

```text
Pushing artifact to harbor.example.com/demo/oras-sample:v1
Artifact type: application/vnd.demo.files.v1+json
Uploading [====================] 100%
Push completed.
```

### Pull

```text
Pulling harbor.example.com/demo/oras-sample:v1 into /path/to/client/out
Pulled files:
total 16
-rw-r--r-- ... README.md
-rw-r--r-- ... hello.txt
-rw-r--r-- ... metadata.json
```

### Verify

```text
Verified: README.md
Verified: hello.txt
Verified: metadata.json
All files verified successfully.
```
