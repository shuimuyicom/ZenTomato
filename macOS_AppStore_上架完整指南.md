# 📱 macOS App Store 上架完整指南 - ZenTomato

> 本文档为第一次上架macOS应用到App Store的完整操作指南，包含每个步骤的详细说明和每个字段的填写要求。

## 目录
1. [准备阶段](#准备阶段)
2. [开发者账号注册](#开发者账号注册)
3. [证书和配置文件](#证书和配置文件)
4. [App Store Connect配置](#app-store-connect配置)
5. [Xcode项目配置](#xcode项目配置)
6. [构建和上传](#构建和上传)
7. [提交审核](#提交审核)
8. [常见问题](#常见问题)

---

## 准备阶段

### 必备条件清单
- [ ] Mac电脑（运行最新版macOS）
- [ ] Xcode（最新版本）
- [ ] Apple ID
- [ ] 信用卡或支付方式（支付年费）
- [ ] 应用图标（1024×1024 PNG格式）
- [ ] 应用截图（至少一张）
- [ ] 应用描述文案
- [ ] 隐私政策URL（如果应用收集用户数据）

### 费用说明
- **个人开发者账号**：$99美元/年（约¥688/年）
- **公司开发者账号**：$99美元/年（需要邓白氏编码）

---

## 开发者账号注册

### 第1步：访问开发者网站
1. 打开浏览器访问：https://developer.apple.com
2. 点击右上角 **"Account"**
3. 使用你的Apple ID登录

### 第2步：加入Apple Developer Program
1. 点击 **"Join the Apple Developer Program"**
2. 选择 **"Start Your Enrollment"**

### 第3步：选择账号类型
- **个人（Individual）**
  - 适合：个人开发者
  - 需要：身份证信息
  - 显示：你的真实姓名
  
- **组织（Organization）**
  - 适合：公司或团队
  - 需要：邓白氏编码（D-U-N-S Number）
  - 显示：公司名称

### 第4步：填写个人信息
**必填字段：**
- **Legal First Name（名）**：你的名字拼音，如：Muyi
- **Legal Last Name（姓）**：你的姓氏拼音，如：Shui
- **Phone Number**：+86 你的手机号
- **Address Line 1**：详细地址英文（如：Room 101, Building 1）
- **Address Line 2**：街道名称（如：Zhongshan Road）
- **City**：城市名（如：Shanghai）
- **State/Province**：省份（如：Shanghai）
- **Postal Code**：邮编（如：200001）
- **Country**：China

### 第5步：同意协议并支付
1. 勾选所有协议条款
2. 选择支付方式（支持支付宝、微信、信用卡）
3. 支付$99美元年费
4. 等待账号激活（通常48小时内）

---

## 证书和配置文件

### 第1步：创建App ID
1. 登录 https://developer.apple.com/account
2. 点击 **"Certificates, Identifiers & Profiles"**
3. 选择 **"Identifiers"** → 点击 **"+"**

**填写字段：**
- **Register**：选择 "App IDs"
- **Type**：选择 "App"
- **Description**：ZenTomato
- **Bundle ID**：选择 "Explicit"
- **输入**：com.shuimuyi.ZenTomato（必须与项目中一致）
- **Capabilities**：勾选需要的功能
  - ✅ App Sandbox（必选）
  - ✅ Hardened Runtime（必选）
  - [ ] 其他根据需求选择

### 第2步：创建证书

#### A. 创建开发证书（Development）
1. 点击 **"Certificates"** → **"+"**
2. 选择 **"Mac Development"**
3. 按照提示创建CSR文件：
   - 打开"钥匙串访问"（Keychain Access）
   - 菜单栏：证书助理 → 从证书颁发机构请求证书
   - **用户电子邮件地址**：你的邮箱
   - **常用名称**：你的名字
   - **请求是**：存储到磁盘
   - 保存CSR文件
4. 上传CSR文件
5. 下载证书并双击安装

#### B. 创建发布证书（Distribution）
1. 重复上述步骤
2. 选择 **"Mac App Distribution"**
3. 使用相同或新的CSR文件
4. 下载并安装证书

### 第3步：创建配置文件

#### A. 开发配置文件
1. 点击 **"Profiles"** → **"+"**
2. 选择 **"macOS App Development"**
3. **App ID**：选择 com.shuimuyi.ZenTomato
4. **Certificate**：选择刚创建的开发证书
5. **Profile Name**：ZenTomato Development
6. 下载并双击安装

#### B. 发布配置文件
1. 点击 **"+"**
2. 选择 **"Mac App Store"**
3. **App ID**：选择 com.shuimuyi.ZenTomato
4. **Certificate**：选择发布证书
5. **Profile Name**：ZenTomato Distribution
6. 下载并双击安装

---

## App Store Connect配置

### 第1步：创建App
1. 访问 https://appstoreconnect.apple.com
2. 点击 **"我的App"**
3. 点击 **"+"** → **"新建App"**

### 第2步：填写基本信息

**新建App字段：**
- **平台**：✅ macOS
- **名称**：禅番茄 - 专注时间管理
  - 限制：30个字符
  - 建议：简洁明了，包含关键词
- **主要语言**：简体中文
- **套装ID**：com.shuimuyi.ZenTomato
- **SKU**：ZENTOMATO001
  - 说明：唯一标识符，不对外显示
  - 格式：字母数字，无空格
- **用户访问权限**：完全访问权限

### 第3步：App信息配置

点击创建后的App，配置以下信息：

#### A. 常规信息
**App信息页面：**
- **类别**：
  - 主要：效率（Productivity）
  - 次要：教育（Education）
- **内容版权**：© 2025 水木易
- **年龄分级**：
  - 点击"编辑"
  - 全部选择"无"（如果应用无不适内容）
  - 年龄：4+

#### B. 本地化信息
**简体中文版本：**
- **名称**：禅番茄 - 专注时间管理
- **副标题**：番茄工作法，提升专注力（30字符内）
- **隐私政策URL**：https://yourwebsite.com/privacy（如不收集数据可留空）
- **支持URL**：https://yourwebsite.com/support（必填）

#### C. 描述文案（4000字符内）
```
禅番茄是一款优雅简洁的番茄工作法时间管理工具，专为macOS设计。

【核心功能】
• 标准番茄钟：25分钟专注时间 + 5分钟休息
• 自定义时长：根据个人习惯调整工作和休息时间
• 任务管理：记录每个番茄钟的任务内容
• 统计分析：查看专注时长和完成情况
• 声音提醒：柔和的提示音，不打扰工作
• 菜单栏快捷操作：随时启动和暂停

【使用场景】
• 学习备考：保持高效专注，避免分心
• 工作办公：合理安排时间，提升效率
• 创意写作：集中精力，激发灵感
• 编程开发：深度工作，减少中断

【为什么选择禅番茄】
• 原生macOS应用，流畅稳定
• 界面简洁优雅，专注核心功能
• 完全免费，无广告无内购
• 尊重隐私，不收集任何数据
• 持续更新，不断优化体验

让禅番茄成为你的专注伙伴，培养良好的工作习惯，提升时间管理能力。
```

#### D. 关键词（100字符内）
```
番茄钟,番茄工作法,专注,时间管理,效率,pomodoro,计时器,提醒,学习,工作
```

#### E. 技术支持信息
- **支持URL**：必填（如：https://github.com/yourusername/zentomato）
- **营销URL**：选填
- **隐私政策URL**：
  - 如果收集数据：必填
  - 如果不收集：可留空，但建议填写

### 第4步：价格与销售范围

**定价：**
- **价格**：免费
  - 或选择付费等级（¥6、¥12、¥18等）
- **销售范围**：
  - ✅ 中国大陆
  - ✅ 香港
  - ✅ 台湾
  - ✅ 美国
  - 可选择所有地区

### 第5步：准备提交材料

#### A. 应用截图
**要求：**
- **格式**：PNG或JPEG
- **尺寸**：以下任一尺寸
  - 1280 × 800
  - 1440 × 900
  - 2560 × 1600
  - 2880 × 1800
- **数量**：1-10张
- **内容建议**：
  1. 主界面截图
  2. 计时中界面
  3. 设置界面
  4. 统计界面
  5. 菜单栏功能

#### B. 应用图标
- **尺寸**：1024 × 1024
- **格式**：PNG（无透明通道）
- **注意**：不要预先添加圆角

#### C. 版本信息
- **版本号**：1.0.0
- **构建号**：1
- **此版本的新增内容**：
  ```
  首次发布
  - 番茄钟计时功能
  - 自定义时长设置
  - 声音提醒
  - 菜单栏快捷操作
  ```

---

## Xcode项目配置

### 第1步：基本设置
1. 打开Xcode项目
2. 选择项目根目录
3. 选择Target

### 第2步：General配置
- **Display Name**：禅番茄
- **Bundle Identifier**：com.shuimuyi.ZenTomato
- **Version**：1.0.0
- **Build**：1
- **Minimum Deployments**：macOS 11.0（根据需求）

### 第3步：Signing & Capabilities
- **Team**：选择你的开发者账号
- **Signing Certificate**：
  - Debug：Mac Development
  - Release：Mac App Distribution
- **Provisioning Profile**：
  - Debug：ZenTomato Development
  - Release：ZenTomato Distribution

#### 添加必要的Capabilities：
1. 点击 **"+ Capability"**
2. 添加：
   - ✅ **App Sandbox**
   - ✅ **Hardened Runtime**
   
#### App Sandbox配置：
- **Incoming Connections**：❌（除非需要网络服务器功能）
- **Outgoing Connections**：❌（除非需要联网）
- **User Selected File**：Read（如果需要读取文件）
- **Downloads Folder**：❌
- **Pictures Folder**：❌
- **Music Folder**：❌
- **Movies Folder**：❌
- **Printing**：❌
- **Audio Input**：❌
- **Camera**：❌
- **USB**：❌

#### Hardened Runtime配置：
- **Allow Execution of JIT-compiled Code**：❌
- **Allow Unsigned Executable Memory**：❌
- **Allow DYLD Environment Variables**：❌
- **Disable Library Validation**：❌
- **Disable Executable Memory Protection**：❌
- **Camera Access**：❌
- **Audio Input**：❌

### 第4步：Build Settings
搜索并设置以下项：
- **Code Signing Identity**：
  - Debug：Apple Development
  - Release：Apple Distribution
- **Development Team**：你的Team ID
- **Code Signing Style**：Manual
- **Provisioning Profile**：
  - Debug：ZenTomato Development
  - Release：ZenTomato Distribution
- **Enable Hardened Runtime**：Yes
- **Other Code Signing Flags**：--deep --timestamp

---

## 构建和上传

### 第1步：Archive构建
1. 选择菜单：**Product** → **Scheme** → **Edit Scheme**
2. 确保Run设置为Release
3. 选择目标设备：**My Mac**
4. 菜单：**Product** → **Archive**
5. 等待构建完成

### 第2步：验证Archive
Archive完成后，Organizer窗口自动打开：
1. 选择刚构建的Archive
2. 点击 **"Validate App"**
3. 选择选项：
   - **Upload your app's symbols**：✅
   - **Manage Version and Build Number**：✅
4. 点击 **"Next"**
5. 等待验证完成

### 第3步：上传到App Store Connect
1. 验证通过后，点击 **"Distribute App"**
2. 选择 **"App Store Connect"**
3. 选择 **"Upload"**
4. 选项保持默认：
   - **Upload your app's symbols**：✅
   - **Manage Version and Build Number**：✅
5. 点击 **"Next"** → **"Upload"**
6. 等待上传完成（可能需要10-30分钟）

### 第4步：处理状态
上传完成后：
1. 登录App Store Connect
2. 状态会显示"正在处理"
3. 等待15-60分钟
4. 处理完成后会收到邮件通知

---

## 提交审核

### 第1步：选择构建版本
1. 在App Store Connect中打开你的App
2. 点击 **"macOS App"** → **"1.0 准备提交"**
3. 在"构建"部分，点击 **"+"**
4. 选择刚上传的构建
5. 点击 **"完成"**

### 第2步：填写审核信息

#### A. 审核备注（可选但建议填写）
```
这是一款番茄工作法时间管理工具。

主要功能：
1. 番茄钟计时（25分钟工作+5分钟休息）
2. 自定义时长设置
3. 声音提醒功能
4. 菜单栏快捷操作

测试说明：
- 点击菜单栏图标可以打开主界面
- 点击"开始"按钮启动计时
- 可在设置中调整时长

应用不收集任何用户数据，不需要网络连接。
```

#### B. 联系信息
- **名字**：你的名字
- **姓氏**：你的姓氏
- **电话**：+86 手机号
- **邮箱**：你的邮箱

#### C. 登录信息
- 如果应用需要登录：提供测试账号
- 如果不需要：选择"不需要登录"

### 第3步：最终检查
确认所有必填项：
- [ ] App信息完整
- [ ] 价格设置正确
- [ ] 截图已上传
- [ ] 描述文案无误
- [ ] 构建版本已选择
- [ ] 联系信息已填写

### 第4步：提交审核
1. 滚动到页面顶部
2. 点击 **"添加以供审核"**
3. 确认弹窗，点击 **"提交至App审核"**

---

## 审核流程

### 时间预期
- **首次审核**：24-48小时
- **后续更新**：24小时左右
- **加急审核**：可申请，通常12小时内

### 审核状态
1. **等待审核**（Waiting for Review）
2. **正在审核**（In Review）
3. **审核通过**：
   - **等待开发人员发布**（Pending Developer Release）
   - **准备销售**（Ready for Sale）
4. **被拒绝**（Rejected）

### 常见拒绝原因
1. **功能不完整**：确保所有功能正常工作
2. **崩溃问题**：充分测试，避免崩溃
3. **元数据问题**：描述与实际功能不符
4. **设计问题**：界面过于简陋
5. **隐私问题**：未说明数据使用

### 被拒后的处理
1. 仔细阅读拒绝原因
2. 修复问题
3. 在"解决方案中心"回复
4. 重新提交构建
5. 等待再次审核

---

## 发布管理

### 发布选项
审核通过后，有两种发布方式：
1. **自动发布**：审核通过立即上架
2. **手动发布**：自己控制上架时间

### 手动发布步骤
1. 审核通过后，状态为"等待开发人员发布"
2. 点击 **"发布此版本"**
3. 确认发布
4. 等待1-24小时全球同步

---

## 常见问题

### Q1：开发者账号多久激活？
**A**：通常48小时内，如果超过请联系Apple支持。

### Q2：可以修改Bundle ID吗？
**A**：上架后不能修改，请仔细确认。

### Q3：审核被拒怎么办？
**A**：根据反馈修改，通常第二次审核会更快。

### Q4：可以随时下架吗？
**A**：可以，在"价格与销售范围"中移除所有地区。

### Q5：更新版本流程？
**A**：创建新版本 → 上传新构建 → 填写更新说明 → 提交审核。

### Q6：如何查看下载量？
**A**：App Store Connect → App分析 → 查看数据。

### Q7：用户评论如何回复？
**A**：在"评分与评论"中可以回复用户。

### Q8：可以修改价格吗？
**A**：可以随时修改，生效需要几小时。

### Q9：如何申请加急审核？
**A**：联系我们 → 申请加急审核 → 说明紧急原因。

### Q10：支持内购吗？
**A**：需要在App Store Connect配置内购项目。

---

## 实用链接

- **Apple Developer**：https://developer.apple.com
- **App Store Connect**：https://appstoreconnect.apple.com
- **审核指南**：https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines**：https://developer.apple.com/design/human-interface-guidelines/
- **开发者论坛**：https://developer.apple.com/forums/
- **技术支持**：https://developer.apple.com/support/

---

## 注意事项

### ⚠️ 重要提醒
1. **Bundle ID一旦确定不能修改**
2. **首次上架审核较严格，准备充分**
3. **保持联系方式畅通，审核团队可能电话联系**
4. **不要在描述中提及其他平台（如Windows、Android）**
5. **不要使用Apple的商标词汇**
6. **确保所有功能在最新macOS版本正常工作**

### ✅ 成功秘诀
1. **界面精美**：第一印象很重要
2. **功能完整**：不要有"即将推出"的功能
3. **描述准确**：与实际功能一致
4. **响应及时**：快速回复审核团队
5. **持续更新**：保持应用活跃

---

## 总结

恭喜你完成了所有准备工作！上架App Store虽然步骤较多，但按照本指南一步步操作，你的禅番茄应用很快就能与全球用户见面。

记住：
- 第一次总是最难的，之后会越来越熟练
- 遇到问题不要慌，Apple的文档和支持都很完善
- 保持耐心，审核需要时间

祝你的应用大获成功！🎉

---

*最后更新：2025年1月*
*作者：水木易*