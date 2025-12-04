# Bingo
此專案為電腦網路程式課程實作，旨在運用 Flutter 與 Dart 語言，透過底層 Socket 傳輸技術，構建一個即時互動的多人連線遊戲。

#系統架構與技術細節： 
Client-Server 通訊架構： 系統分為伺服器端（Server）與客戶端（Client）。Server 端綁定 IP 0.0.0.0 與 Port 12345 建立監聽服務，確保能同時處理多個客戶端連線請求。
即時資料同步機制： 

狀態廣播： 當任一玩家選取數字時，Client 透過 _sendMessage 函式將數據傳送至 Server 。Server 接收後即時廣播給所有連線中的玩家，觸發客戶端自動變色機制，確保所有人的盤面狀態同步 。 
勝負判定邏輯： 當某位玩家達成連線條件時，系統會向 Server 發送獲勝訊號。Server 解析後會針對該玩家回傳 "Win"，並同時向其他所有玩家廣播 "Lose" 訊號，精準控制遊戲結束的畫面切換
異常處理與連線維護： 在 Client 端的 _initSocket 函式中，運用 try-catch 區塊處理連線異常，並實作 onDone 與 onError 監聽器，確保在斷線或傳輸錯誤時能正確釋放資源（socket.destroy()），提升應用程式的穩定性 。
<img width="1275" height="751" alt="image" src="https://github.com/user-attachments/assets/c8ef9102-7432-4dd0-891c-8cb693ebd1be" />


Demo連結： https://youtu.be/PBWWR7qGwL4 
