<!--
---
Sync Impact Report
---
- **Version Change**: 1.0.0 → 1.1.0
- **New Principles**:
    - V. 文件一致性 (Document Consistency)
- **Templates Checked**:
    - ✅ .specify/templates/plan-template.md
    - ✅ .specify/templates/spec-template.md
    - ✅ .specify/templates/tasks-template.md
- **Follow-up TODOs**:
    - None
-->
# r_maze Constitution

## 專案願景 (Project Vision)

打造一個具備高度重玩性、易於上手但難於精通的迷宮探索競技遊戲。

## 核心體驗 (Core Experience)

- **探索的興奮感**： 每次進入都是未知的挑戰，玩家享受在隨機生成的迷宮中尋找出路的過程。
- **精通的成就感**： 玩家透過重複挑戰，學會優化自己的「尋路策略」(Pathfinding) 和「資源收集路線」。
- **競爭的驅動力**： 玩家的最終表現（時間 + 分數）會被記錄在排行榜上，激發玩家超越自我與他人的慾望。

## 指導原則 (Guiding Principles)

### I. 效能優先 (Performance First)
遊戲必須在包含行動裝置在內的所有平台上流暢運行。所有靜態生成的物件（如牆壁、地板）必須被錨定 (Anchored)，並盡可能減少 Part 的數量。

### II. 公平至上 (Fairness is Key)
迷宮的隨機生成必須對所有玩家公平。排行榜系統必須穩健，並盡力防止作弊。

### III. 安全為本 (Security by Design)
嚴格遵守 Roblox 的客戶端/伺服器安全模型。「永遠不信任客戶端」，所有關鍵的遊戲 logique（如計時、計分、物品收集）的最終裁決必須在伺服器 (Script) 上完成。

### IV. 可擴展性 (Scalability)
整體架構應使用 ModuleScript（模組腳本）進行設計，以便未來能輕鬆添加新的迷宮尺寸、主題、陷阱或敵人。

### V. 文件一致性 (Document Consistency)
所有專案文件，包括規格、計畫、任務和程式碼註解，都必須使用繁體中文撰寫，以確保團隊成員之間的溝通清晰一致。

## Governance

本章程是專案開發的最高準則，其效力高於所有其他實踐。任何修訂都必須有文件記錄、團隊批准以及對應的遷移計畫。所有開發工作與審查都必須驗證是否符合本章程。

**Version**: 1.1.0 | **Ratified**: 2025-11-02 | **Last Amended**: 2025-11-02
