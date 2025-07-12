# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリでコードを扱う際のガイダンスを提供します。

## プロジェクト概要

これは**dbt（data build tool）売上レポートプロジェクト**で、自動販売機の売上データを3層アーキテクチャ（**staging → intermediate → marts**）を使用して分析します。

## 環境構成

### プロジェクト構造
```
dbtbook/
├── dbt_env/          # Python仮想環境
└── sales_report/     # dbtプロジェクトディレクトリ
    ├── dbt_project.yml
    ├── models/
    ├── sources/
    └── tests/
```

### 仮想環境の使用
このプロジェクトではPython仮想環境（`dbt_env/`）を使用しています。作業前に必ず仮想環境をアクティベートしてください。

```bash
# 仮想環境をアクティベート
source dbt_env/bin/activate

# 作業完了後は非アクティベート
deactivate
```

## アーキテクチャ

### データフロー
- **Stagingレイヤー**: 自動販売機、商品、売上の生CSVデータ
- **Intermediateレイヤー**: 売上データのインクリメンタル処理を含む、クリーニング・型変換済みデータ
- **Martsレイヤー**: ビジネスロジックと集計レポートモデル

### スキーマ構成
- `sales_report_staging` - 生ソースデータ
- `intermediate` - クリーニング・標準化されたモデル
- `marts` - ビジネスレポートモデル

### 主要モデル
- **`sale.sql`** - 売上トランザクションのインクリメンタルモデル（パフォーマンス重要）
- **`mart_sale.sql`** - 設定可能なstart_date変数を使用してフィルタリングされた売上データ
- **レポートモデル** - 商品別・自動販売機別の日次集計

## よく使用するコマンド

**重要**: 全てのdbtコマンドは仮想環境をアクティベートしてから実行してください。

### 環境セットアップ
```bash
# 仮想環境をアクティベート
source dbt_env/bin/activate

# プロジェクトディレクトリに移動
cd sales_report
```

### 開発ワークフロー
```bash
# 仮想環境内で実行
# 全てのビルドとテスト
dbt run && dbt test

# レイヤー固有の開発
dbt run --select staging
dbt run --select intermediate
dbt run --select marts
dbt test --select staging
dbt test --select intermediate
dbt test --select marts

# インクリメンタルモデル管理
dbt run --full-refresh              # 全インクリメンタルモデルの再構築
dbt run --select sale --full-refresh   # 特定インクリメンタルモデルの再構築

# 日付フィルタリングのための変数オーバーライド
dbt run --vars '{"start_date": "2025-02-01"}'
```

### テストコマンド
```bash
# 仮想環境内で実行
# 特定のテストタイプの実行
dbt test --select test_type:generic  # is_integerなどのカスタムテスト
dbt test --select test_type:unit     # モックデータを使用したユニットテスト

# 特定モデルのテスト
dbt run --select item && dbt test --select item
```

### ドキュメント生成
```bash
# 仮想環境内で実行
dbt docs generate && dbt docs serve
```

## 開発ノート

### 重要な設定
- **開始日変数**: `start_date: '2025-01-01'`がmartsレイヤーでのデータフィルタリングを制御
- **インクリメンタル戦略**: `sale.sql`がパフォーマンスのためにインクリメンタルマテリアライゼーションを使用
- **スキーマエイリアス**: `mart_sale`モデルがmartsスキーマで`sale`としてエイリアス化

### テスト戦略
- **ジェネリックテスト**: カスタム`is_integer`テストがデータ型を検証
- **ユニットテスト**: `_unittest.yml`ファイルでの包括的なモックデータテスト
- **ソーステスト**: ソース列でのデータ品質検証

### データソース
- `sources/`ディレクトリ内の日次売上データCSVファイル（2025-01-01〜2025-01-30）
- `models/source/source.yml`でのソース定義
- モデルYAMLファイル内の日本語ドキュメント

### このプロジェクトでの作業時の注意点
1. **仮想環境の使用**: 全てのdbtコマンド実行前に必ず`source dbt_env/bin/activate`で仮想環境をアクティベート
2. **作業ディレクトリ**: dbtコマンドは`sales_report/`ディレクトリ内で実行
3. スキーマ変更時は常にインクリメンタルモデルを`--full-refresh`でテスト
4. 特定レイヤーでの高速開発には`--select`フラグを使用
5. martsモデルのビジネスロジック変更時はユニットテストを確認
6. martsレイヤーモデル変更時は日付変数の影響を考慮