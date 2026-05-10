# Rday

> 倒计时 · 待办清单 · 跑马灯 — 记录你的每一天

Rday 是一款 iOS 生活工具应用，集倒计时、待办清单与全屏跑马灯于一体。使用 SwiftUI + SwiftData 构建，支持 iOS 17+。

## 功能

- **⏳ 倒计时** — 为重要日子创建精美倒计时卡，支持分类标签、自定义颜色、一键分享
- **✅ 待办清单** — 轻量任务管理，优先级标记、截止日期提醒、邮件发送
- **💡 跑马灯** — 全屏 LED 滚动字幕，自由调整字体、颜色、速度与方向

| 倒计时 | 待办 | 跑马灯 |
|:---:|:---:|:---:|
| 卡片式布局，分类筛选 | 优先级标记，滑动操作 | 全屏横竖屏滚动 |

## 技术栈

- **SwiftUI** — 声明式 UI
- **SwiftData** — 本地数据持久化
- **Swift 6.0** — 严格并发
- **Xcode 16 / iOS 17+**

## 预览地址

| 部署端 | 地址 |
|:---|:---|
| 🌐 VPS (域名一) | [https://rday.ssdwgg.site](https://rday.ssdwgg.site) |
| 🌐 VPS (域名二) | [https://rday.aiwgg.cn](https://rday.aiwgg.cn) |
| 📦 GitHub Pages | [https://ssdwgg.github.io/rday](https://ssdwgg.github.io/rday) |

## 项目结构

```
Rday/
├── Views/
│   ├── Countdown/          # 倒计时视图
│   │   ├── CountdownListView.swift
│   │   ├── CountdownDetailView.swift
│   │   ├── CountdownFormView.swift
│   │   ├── EventCardView.swift
│   │   ├── ShareCardView.swift
│   │   ├── CategoryChipView.swift
│   │   ├── CategoryPickerView.swift
│   │   ├── ColorPresetPickerView.swift
│   │   └── DateCalculatorView.swift
│   ├── Todo/               # 待办视图
│   │   ├── TodoListView.swift
│   │   ├── TodoDetailView.swift
│   │   ├── TodoFormView.swift
│   │   └── TodoRowView.swift
│   └── Common/             # 公共组件
│       ├── EmptyStateView.swift
│       └── PriorityBadgeView.swift
├── ViewModels/             # 视图模型
├── Models/                 # 数据模型 (SwiftData)
├── Services/               # 服务层 (通知/邮件)
├── Extensions/             # 扩展
├── Utilities/              # 工具类
└── Design/                 # 设计系统
```

## 构建

```bash
# 使用 Xcode
open Rday.xcodeproj

# 或使用 xcodegen（若已安装）
xcodegen generate
```

## License

MIT
