//
//  ShopListViewController.swift
//  wiki_1
//
//  Created by 釜谷 on 2018/09/04.
//  Copyright © 2018年 Regina. All rights reserved.
//

import UIKit


class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    テーブルビュー
    @IBOutlet weak var tableview: UITableView!
    
//    YahooAPI、データ取得用構造体
    var yls: YahooLocalSearch = YahooLocalSearch()

//    非同期通知用
    var loadDataObserver: NSObjectProtocol?
    var refreshObserver: NSObjectProtocol?
    var changeFavoriteObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        table用イベント受信登録
        tableview.delegate = self;
        tableview.dataSource = self;
  
//        Refresh操作有効設定
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ShopListViewController.onRefresh(_:)), for: .valueChanged)
        self.tableview.addSubview(refreshControl)
  
//        お気に入り画面から来た時は、NavigatonBarの右ボタンを消す
        if !(self.navigationController is FavoriteNavigationController) {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        var qc = QueryCondition()
//        qc.query = "ハンバーガー"
//        yls = YahooLocalSearch(condition: qc)

//        YahooAPIからデータ取得完了通知を受信
        loadDataObserver = NotificationCenter.default.addObserver(forName: .apiLoadComplete, object: nil, queue: nil, using: {
            (notification) in
            
            print("API complete request")
            
            if self.yls.condition.gid != nil {
                self.yls.sortByGid()
            }
            
            self.tableview.reloadData()
            
            if notification.userInfo != nil {
                if let userInfo = notification.userInfo as? [String: String] {
                    if userInfo["error"] != nil {
                        let alertView = UIAlertController(title: "通信エラー",
                                                          message: "通信エラーが発生しました。",
                                                          preferredStyle: .alert)
    
                        alertView.addAction(
                            UIAlertAction(title: "OK", style: .default) {
                                action in return
                            }
                        )
                        self.present(alertView,
                                     animated: true, completion: nil)
                    }
                }
            }
        })
        
        //  note: Test実装処理
        changeFavoriteObserver = NotificationCenter.default.addObserver(forName: .changeFavorite, object: nil, queue: nil, using: { (notification) in
            
            self.loadFavorites()
            })
        //
        
        //  表示情報数が0のとき
        if yls.shops.count == 0 {
        
//            タイトル表示設定、表示情報取得開始
            if self.navigationController is FavoriteNavigationController {
                loadFavorites()
                self.navigationItem.title = "お気に入り"
            } else {
                yls.loadData(reset: true)
                self.navigationItem.title = "店舗一覧"
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        Notification購読の解放　メモリリーク対策
        NotificationCenter.default.removeObserver(self.loadDataObserver!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - App logic
    
//  表示情報取得開始　お気に入り
    func loadFavorites() {

        // データ領域にデータ取得
        Favorite.load()

        // 表示するお気に入りが存在するとき
        if Favorite.favorites.count > 0 {
            
            // YahooAPIに指定する情報作成　お気に入りのIDリストを作成
            var conditiion = QueryCondition()
            conditiion.gid = Favorite.favorites.joined(separator: ",")
            yls.condition = conditiion
            yls.loadData(reset: true)
        } else {
//            お気に入りがないとき、YahooAPIを使用しないので、データ取得完了通知を投げる
            NotificationCenter.default.post(name: .apiLoadComplete, object: nil)
        }
    }
    
    // リフレッシュ
    @objc func onRefresh(_ refreshControl: UIRefreshControl) {
        // 更新中アイコンを表示する
        refreshControl.beginRefreshing()
        
//        データ取得完了通知の購読
//        更新中アイコンを非表示にする
        refreshObserver
            = NotificationCenter.default.addObserver(forName: .apiLoadComplete,
                                                     object: nil,
                                                     queue: nil, using: {
                                                     notification in
                                                                    
                                                        NotificationCenter.default.removeObserver(self.refreshObserver!)
                                                        refreshControl.endRefreshing()
        })
        
        // 表示種別に応じた表示情報を取得する
        if self.navigationController is FavoriteNavigationController {
            loadFavorites()
        } else {
            yls.loadData(reset: true)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択中項目の選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 詳細表示へ遷移
        performSegue(withIdentifier: "PushShopDetail", sender: indexPath)
    }
 
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // tableviewの編集機能有効無効を返す
        return self.navigationController is FavoriteNavigationController
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 削除機能を使用中　選択項目を削除する
        if editingStyle == .delete {
            guard let gid = yls.shops[indexPath.row].gid else {
                return
            }
            
            Favorite.remove(gid)
            yls.shops.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // tableviewの入れ替え機能有効無効を返す
        return self.navigationController is FavoriteNavigationController
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 入れ替え処理
        if sourceIndexPath == destinationIndexPath { return }
        
        let source = yls.shops[sourceIndexPath.row]
        yls.shops.remove(at: sourceIndexPath.row)
        yls.shops.insert(source, at: destinationIndexPath.row)
        
        Favorite.move(sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return yls.shops.count
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
//            表示位置がデータ数以内のとき
            if indexPath.row < yls.shops.count {

                // Cellを作成　Cellに表示情報を設定
                let cell = tableview.dequeueReusableCell(withIdentifier: "ShopListItem") as! ShopListItemTableViewCell
                cell.shop = yls.shops[indexPath.row]
            
                // スクロールしたときは、必要な表示情報を再取得
                if yls.shops.count < yls.total {
                    if yls.shops.count - indexPath.row <= 4 {
                        yls.loadData()
                    }
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushShopDetail" {
            let vc = segue.destination as! ShopDetailViewController
            if let indexPath = sender as? IndexPath {
                vc.shop = yls.shops[indexPath.row]
            }
        }
    }

    // MARK: - IBAction
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if tableview.isEditing {
            tableview.setEditing(false, animated: true)
            sender.title = "編集"
        } else {
            tableview.setEditing(true, animated: true)
            sender.title = "完了"
        }
    }
}

