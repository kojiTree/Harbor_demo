# Harbor_demo

## serverのみのデモ

| 項目                      | できる？          |
| ----------------------- | ------------- |
| Harbor 単体起動             | ✅             |
| UI デモ                   | ✅             |
| Project / User / Policy | ✅             |
| OCI Registry としての説明     | ✅             |
| Artifact の push/pull    | ❌（client が必要） |

```text
Harbor_demo/
├── server/harbar
│   ├── harbor.yml
│   ├── docker-compose.yml
│   ├── install.sh
│   └── data/
└── client/   ←（あとで ORAS デモ）
```

### install: harbor

offline-installerを持ってくる：
https://github.com/goharbor/harbor/releases
とりあえず、
`server`フォルダに置く

展開：

```bash
cd server
tar xzvf harbor-offline-installer-v2.14.1.tgz 
```
`harbor`フォルダが生まれる。

```sh
cd server/harbor
cp harbor.yml.tmpl harbor.yml
```
その後、harbor.ymlを修正

### /etc/hosdts 設定

```bash
sudo nano /etc/hosts
```

```text
127.0.0.1 harbor.local
```

### 起動

```bash
sudo ./install.sh
```

成功したら：

```bash
docker ps
```

#### 以降再起動時
止まっていたら「起動」する
```bash
cd server/harbor
sudo docker compose up -d
```


## ここまで来たら「Harbor server 単体デモ完成」

* UI が開く（wsl環境の場合、windoesホスト側で、http://localhost）
* Project 作れる
* 「ここが OCI Registry」と説明できる

### harbor-db
内容確認
```sh
docker exec -it harbor-db bash
psql -U postgres -d registry
\d artifact
```
