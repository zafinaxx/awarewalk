# AwareWalk 上架完整指南

> 你已经在 App Store Connect 创建好了 App 页面。  
> 下面是**剩余每一步的详细操作**。照着做就行。

---

## 第一步：填写「App 信息」（3 分钟）

打开 App Store Connect → AwareWalk → 左侧菜单「**App 信息**」

### 1.1 本地化信息

右上角语言切换，分别填 3 种语言：

**English (U.S.)：**

| 字段 | 填写内容 |
|------|---------|
| 名称 | `AwareWalk` |
| 副标题 | `Spatial Safety HUD for Vision` |

**日本語：**

| 字段 | 填写内容 |
|------|---------|
| 名称 | `AwareWalk` |
| 副标题 | `空間安全HUD - ビジョンプロ対応` |

**한국어：**

| 字段 | 填写内容 |
|------|---------|
| 名称 | `AwareWalk` |
| 副标题 | `공간 안전 HUD - 비전 프로` |

### 1.2 分类

| 字段 | 选择 |
|------|------|
| 主要分类 | **工具（Utilities）** |
| 次要分类 | **导航（Navigation）** |

### 1.3 内容版权

选择 → **此 App 不包含、展示或访问第三方内容**

点右上角 **「存储」**

---

## 第二步：填写「定价和销售范围」（1 分钟）

左侧菜单 → **「定价和销售范围」**

| 字段 | 选择 |
|------|------|
| 价格 | **免费** |
| 销售范围 | 点「编辑」→ 勾选 ☑️ **美国**、☑️ **日本**、☑️ **韩国** |

> 💡 如果想全球发布，直接点「选择全部」也行

点 **「存储」**

---

## 第三步：填写「App 隐私」（2 分钟）

左侧菜单 → **「App 隐私」**

### 3.1 隐私政策 URL

填入：
```
https://jingjingapp.github.io/awarewalk-privacy/
```

> ⚠️ 这个 URL 需要先托管好（见第八步），如果还没托管，先填一个临时的，提交前改回来

### 3.2 数据收集

1. 点 **「开始使用」**
2. 问「你的 App 是否会收集数据？」→ 选 **「是，收集数据」**
3. 勾选 ☑️ **位置** → 点「下一步」
4. 位置数据的用途：
   - ☑️ App 功能
   - 不勾选「与用户身份关联」
   - 不勾选「用于追踪」
5. 点 **「发布」**

---

## 第四步：创建订阅产品（10 分钟）

左侧菜单 → **「订阅」**

### 4.1 创建订阅组

1. 点 **「+」** 按钮
2. 参考名称填：`AwareWalk Pro`
3. 点 **「创建」**

### 4.2 添加月订阅

1. 在「AwareWalk Pro」组内点 **「+」**（创建订阅）
2. 填写：

| 字段 | 值 |
|------|------|
| 参考名称 | `Pro Monthly` |
| 产品 ID | `com.jingjing.AwareWalk.pro.monthly` |

3. 点 **「创建」**
4. 进入该产品页面，填写：

**订阅时长：** 选 `1 个月`

**订阅价格：**
- 点 **「+」**（添加订阅价格）
- 基础国家/地区选 **美国**
- 价格选 **$2.99**
- 点 **「下一步」** → 系统会自动生成所有地区价格
- 点 **「创建」**

**本地化信息：**
点 **「+」** 添加语言，逐个填写：

| 语言 | 显示名称 | 描述 |
|------|---------|------|
| English (U.S.) | Monthly | Full access to all themes and features |
| 日本語 | 月額プラン | 全テーマ・全機能へのフルアクセス |
| 한국어 | 월간 플랜 | 모든 테마 및 기능에 대한 전체 액세스 |

**审核信息：**
- 截图：先跳过，后面补
- 审核备注填：`Subscription unlocks all premium themes and advanced navigation features`

点 **「存储」**

### 4.3 添加年订阅

同样步骤：

| 字段 | 值 |
|------|------|
| 参考名称 | `Pro Yearly` |
| 产品 ID | `com.jingjing.AwareWalk.pro.yearly` |
| 订阅时长 | 1 年 |
| 价格 | $24.99 |

本地化信息：

| 语言 | 显示名称 | 描述 |
|------|---------|------|
| English (U.S.) | Yearly | Best value — save 30% vs monthly |
| 日本語 | 年額プラン | 最もお得 — 月額より30%節約 |
| 한국어 | 연간 플랜 | 최고 가치 — 월간 대비 30% 절약 |

### 4.4 添加终身购买（非消耗型）

左侧菜单 → **「App 内购买项目」**（不是「订阅」）

1. 点 **「+」** → 选 **「非消耗型」**
2. 填写：

| 字段 | 值 |
|------|------|
| 参考名称 | `Pro Lifetime` |
| 产品 ID | `com.jingjing.AwareWalk.pro.lifetime` |

3. 进入产品页面：

**价格：**
- 点 **「+」** → 美国 → $79.99 → 自动生成所有价格

**本地化信息：**

| 语言 | 显示名称 | 描述 |
|------|---------|------|
| English (U.S.) | Lifetime Pro | One-time purchase — lifetime access to all features |
| 日本語 | 永久ライセンス | 一度の購入で全機能に永久アクセス |
| 한국어 | 평생 라이선스 | 한 번 구매로 모든 기능에 영구 액세스 |

**审核信息：** 截图先跳过，审核备注填 `One-time purchase for lifetime access`

点 **「存储」**

---

## 第五步：填写版本信息「1.0 准备提交」（10 分钟）

左侧菜单 → **「1.0 准备提交」**

### 5.1 截图

visionOS 截图尺寸：**3840 × 2160 px**

在模拟器中运行 App，手动截图（模拟器菜单 → File → Screenshot 或 `Cmd+S`）：

| 序号 | 截什么 |
|------|--------|
| 第 1 张 | 启动页面（守护之眼按钮 + AwareWalk 标题） |
| 第 2 张 | HUD 激活后的主界面 |
| 第 3 张 | 主题选择画廊 |
| 第 4 张 | 设置页面 |

> 每种语言都要上传截图。先做英文的，日文韩文可以之后补

上传截图：拖拽图片到截图区域即可

### 5.2 文案（按语言分别填写）

右上角切换语言，逐个填写：

#### English (U.S.)

| 字段 | 内容 |
|------|------|
| 宣传文本 | `Your spatial guardian — F-35 helmet-style HUD for Apple Vision Pro. Stay aware, stay safe, stay focused.` |
| 描述 | 复制下面的内容 👇 |
| 关键词 | `HUD,spatial,safety,navigation,AR,walking,helmet,display,alert,obstacle,visionpro,awareness,guard` |

英文描述（直接复制）：
```
AwareWalk transforms your Apple Vision Pro into an F-35 fighter pilot-style heads-up display — keeping you aware and safe while walking, commuting, or working.

YOUR GUARDIAN EYE IN AUGMENTED REALITY

• Real-time spatial awareness — detects obstacles, vehicles, and potential hazards around you
• Transparent HUD overlay — critical info at the edge of your vision, never blocking your view
• Smart navigation — turn-by-turn guidance displayed as AR path markers
• Instant notifications — calls, messages, and alerts at a glance without breaking focus
• Threat-level system — color-coded safety indicators from green (safe) to red (danger)

DESIGNED FOR YOUR LIFESTYLE

Whether you're walking down a busy street, working at your desk, or exploring a new city, AwareWalk provides a seamless safety layer that works with you, not against you.

PREMIUM THEMES

Choose from 6 stunning visual themes — Apple Standard (free), Cyberpunk, Japanese Zen, European Classical, Cute Pet, and Military Tactical. Each theme transforms your HUD with unique aesthetics while maintaining full functionality.

PRIVACY FIRST

All spatial data is processed on-device. No data is ever sent to our servers. Your location, your business.

AwareWalk Pro unlocks all themes, advanced navigation features, and priority safety alerts.
```

#### 日本語

| 字段 | 内容 |
|------|------|
| 宣传文本 | `あなたの空間ガーディアン — F-35ヘルメット型HUDでApple Vision Proを安全アシスタントに。` |
| 描述 | 复制 `APP_STORE_METADATA.md` 中日文描述部分 |
| 关键词 | `HUD,空間認識,安全,ナビ,AR,歩行,ヘルメット,障害物,アラート,ビジョンプロ,ヘッドアップ,ガード,戦闘機` |

#### 한국어

| 字段 | 内容 |
|------|------|
| 宣传文本 | `당신의 공간 가디언 — F-35 헬멧형 HUD로 Apple Vision Pro를 안전 어시스턴트로.` |
| 描述 | 复制 `APP_STORE_METADATA.md` 中韩文描述部分 |
| 关键词 | `HUD,공간인식,안전,내비,AR,보행,헬멧,장애물,알림,비전프로,헤드업,가드,전투기,디스플레이` |

### 5.3 其他字段

| 字段 | 填写 |
|------|------|
| 技术支持 URL | `https://jingjingapp.github.io/awarewalk-privacy/` |
| 营销 URL | 留空 |
| 版本 | `1.0.0` |
| 版权 | `2026 jingjing` |

### 5.4 App 审核信息

| 字段 | 填写 |
|------|------|
| 联系人名字 | 填你的名字 |
| 联系人邮箱 | `jingjingapp@outlook.com` |
| 联系人电话 | 填你的电话 |
| 备注 | 复制下面 👇 |

审核备注（直接复制）：
```
AwareWalk is a spatial safety HUD app for Apple Vision Pro. It uses ARKit world sensing for obstacle detection and provides a transparent heads-up display overlay.

To test:
1. Launch the app and tap the Guardian Eye button to activate the HUD
2. The HUD preview will appear in the main window
3. Open Theme Gallery from the bottom toolbar to see available themes
4. Open Settings to configure alerts and navigation

Note: Full AR spatial awareness features (obstacle detection, scene reconstruction) require a physical Apple Vision Pro device. The simulator shows a preview mode with simulated data.

Pro subscription unlocks all premium themes and advanced features. Please use sandbox test accounts to verify in-app purchases.
```

### 5.5 年龄分级

点 **「编辑」** → 所有问题全选 **「无」** → 结果应该是 **4+** → 点 **「完成」**

点右上角 **「存储」**

---

## 第六步：Archive 打包（5 分钟）

1. 打开 Xcode → `AwareWalk.xcodeproj`
2. 顶部设备选择器 → 选 **Any Apple Vision Pro (arm64)**
3. 菜单 **Product → Archive**
4. 等待编译完成（约 2-3 分钟）
5. 编译成功后 **Organizer** 窗口自动弹出

---

## 第七步：上传到 App Store Connect（3 分钟）

1. 在 Organizer 窗口中选中刚才的 Archive
2. 点右侧 **「Distribute App」**
3. 选择 **「App Store Connect」** → 点 **「Distribute」**
4. 选 **「Upload」**（上传到 App Store Connect）
5. 一路点 **Next / Upload**
6. 等待上传完成 → 显示 ✅ 绿色勾表示成功

> ⚠️ 如果提示签名问题：回到 Target → Signing → 确认 Team 选对了
> ⚠️ 如果提示图标问题：确认 AppIcon.solidimagestack 三层都有图片

---

## 第八步：托管隐私政策（5 分钟）

> 如果你之前 Zenith Retreat 已经有 GitHub Pages 仓库，可以在同一个账号下新建仓库

1. 打开 [github.com](https://github.com)
2. 点右上角 **「+」** → **「New repository」**
3. Repository name 填：`awarewalk-privacy`
4. 选 **Public** → 点 **「Create repository」**
5. 点 **「uploading an existing file」**
6. 把 `/Users/jingjing/AwareWalk/docs/privacy/index.html` 拖进去上传
7. 点 **「Commit changes」**
8. 进入仓库 **Settings** → 左侧 **Pages**
9. Source 选 **「Deploy from a branch」** → Branch 选 **main** → 文件夹选 **/ (root)** → 点 **Save**
10. 等 1-2 分钟，页面会显示 URL：
    ```
    https://你的用户名.github.io/awarewalk-privacy/
    ```
11. 打开这个 URL 确认能看到隐私政策页面
12. 回到 App Store Connect → App 隐私 → 更新隐私政策 URL

---

## 第九步：选择构建版本 & 提交审核（2 分钟）

> ⚠️ 上传后构建版本需要 **5-15 分钟** 才会出现在 App Store Connect

1. 回到 App Store Connect → AwareWalk → **「1.0 准备提交」**
2. 滚到 **「构建版本」** 区域
3. 点 **「+」** → 选择刚上传的 Build `1.0.0 (1)`
4. 检查页面右上角没有 ❌ 红色错误
5. 如果有黄色 ⚠️ 警告，通常可以忽略
6. 确认所有必填项都填好了：
   - ☑️ 截图已上传（至少 3 张）
   - ☑️ 描述已填写
   - ☑️ 关键词已填写
   - ☑️ 隐私政策 URL 可访问
   - ☑️ 年龄分级已设置
   - ☑️ 审核联系信息已填写
7. 点右上角 **「添加以供审核」**
8. 点 **「提交至 App Review」**

---

## 提交后

- ⏱ visionOS App 审核通常 **24-48 小时**（visionOS 可能更快）
- 📧 审核结果发送到你的开发者账号邮箱
- ✅ 通过后可以选择手动发布或自动上架
- 🔄 如果被拒，看反馈修改后重新提交

---

## ⚠️ 常见被拒原因和我们的应对

| 可能被拒原因 | 我们的应对 |
|------------|-----------|
| 缺少隐私政策 | ✅ 已准备（三语） |
| 订阅没有恢复购买按钮 | ✅ 代码已有 |
| 未说明订阅条款 | ✅ 订阅页面显示价格和周期 |
| 截图与实际不符 | 用模拟器真实截图 |
| App 在模拟器崩溃 | ✅ ARKit 已做优雅降级 |
| 隐私清单缺失 | ✅ PrivacyInfo.xcprivacy 已创建 |
