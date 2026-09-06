# فارسی ساز محیط توسعه آنتی گرویتی (PersianAntigravityIDE) 🇮🇷 🇦🇪

<div dir="rtl">

> **پشتیبانی بومی، پایدار و بدون نیاز به افزونه از زبان‌های راست‌به‌چپ (فارسی و عربی) و فونت زیبای وزیرمتن در محیط توسعه Antigravity IDE.**

<p align="center">
  <a href="README.md"><b>🇮🇷 مستندات فارسی</b></a> •
  <a href="README.en.md"><b>English Documentation 🇬🇧</b></a>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="مجوز MIT"></a>
  <a href="#"><img src="https://img.shields.io/badge/سیستم‌عامل-لینوکس%20%7C%20ویندوز%20%7C%20مک-informational.svg" alt="پلتفرم‌ها"></a>
  <a href="#"><img src="https://img.shields.io/badge/پشتیبانی-Antigravity%20IDE-blueviolet.svg" alt="محیط هدف"></a>
  <a href="#"><img src="https://img.shields.io/badge/فونت-وزیرمتن-success.svg" alt="فونت وزیرمتن"></a>
</p>

<p align="center">
  <img src="assets/preview.webp" alt="پیش‌نمایش فارسی‌ساز Antigravity IDE" style="max-width: 100%; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">
</p>

---

## 🎯 چرا فارسی ساز محیط توسعه آنتی گرویتی (PersianAntigravityIDE)؟

محیط توسعه **Google Antigravity IDE** به طور پیش‌فرض متون زبان‌های راست‌به‌چپ (مانند فارسی و عربی) را در پنل چت هوش مصنوعی (`Chat Side Panel`) و صفحات برنامه‌ریزی معماری (`Implementation Plans` و `Artifacts`) به صورت چپ‌چین و نامنظم نمایش می‌دهد. افزونه‌های معمول VS Code نیز یا روی Antigravity IDE کار نمی‌کنند یا سرعت محیط را کاهش داده و خطوط کد را به اشتباه راست‌چین می‌کنند.

این پروژه یک راهکار بومی، فوق‌العاده سبک و مهندسی‌شده ارائه می‌دهد که:
- به هیچ افزونه جانبی نیاز ندارد.
- جهت متون فارسی/عربی را به محض تایپ یا استریم شدن پاسخ هوش مصنوعی در همان لحظه تشخیص می‌دهد.
- ساختار و جهت بلوک‌های کد (`LTR`)، جداول و متون انگلیسی را کاملاً دست‌نخورده نگه می‌دارد.

---

## ✨ ویژگی‌های برجسته

- 🚫 **بی‌نیاز از هرگونه اکستنشن:** تزریق مستقیم و تمیز در سطح هسته Workbench، بدون سربار پردازشی یا ناسازگاری افزونه‌ها.
- ⚡ **تشخیص لحظه‌ای و پویا (Dynamic RTL):** استفاده از یک `MutationObserver` سبک و بهینه‌سازی‌شده برای تشخیص متون فارسی، عربی و عبری به صورت Real-Time هنگام استریم پاسخ‌های دستیار هوشمند.
- 🎨 **تایپوگرافی زیبا با فونت وزیرمتن:** اعمال فونت چشم‌نواز Vazirmatn با ارتفاع خط استاندارد (`line-height: 1.8`) در پنل چت و آرتیفکت‌های ویرایشگر (`.jetski-custom-editor-pane`).
- 💻 **حفظ جهت چپ‌به‌راست برای کدها:** تمام بلوک‌های کد (`pre`, `code`, `.interactive-result-code-block`) در جهت دقیق `LTR` با فونت‌های مونواسپیس استاندارد (`JetBrainsMono Nerd Font` و غیره) بدون تغییر جهت باقی می‌مانند.
- 🛡️ **بدون پیام هشدار خرابی نسخه (Checksum Patch):** بازنویسی خودکار و تمیز هش فایل‌ها در `product.json` به طوری که اخطار مزاحم *"Your installation is corrupt"* هرگز نمایش داده نشود.
- 📝 **پیش‌نمایش مارک‌داون راست‌چین:** تنظیم خودکار استایل‌های پیش‌نمایش داخلی Markdown (`Ctrl+Shift+V`) با فونت وزیرمتن و جهت راست‌چین.
- 🔄 **نصب ایمن با قابلیت بازگردانی (Rollback):** ایجاد نسخه پشتیبان (`.bak`) از تمام فایل‌های سیستمی قبل از هرگونه تغییر؛ قابلیت حذف کامل و بازگشت به حالت اولیه تنها با یک دستور.

---

## 🚀 راهنمای نصب سریع (One-Liner Install)

تنها با اجرای یک دستور در ترمینال، تمامی فایل‌ها به طور خودکار دریافت، تنظیم و اعمال می‌شوند:

### 🐧 لینوکس و مک (Linux & macOS)

دستور زیر را در ترمینال (Bash/Zsh) اجرا کنید:

```bash
curl -fsSL https://raw.githubusercontent.com/mehdichamani/PersianAntigravityIDE/main/setup.sh | bash
```

### 🪟 ویندوز (Windows PowerShell)

پنجره PowerShell (ترجیحاً نسخه 7 یا بالاتر) را باز کرده و دستور زیر را وارد کنید:

```powershell
irm https://raw.githubusercontent.com/mehdichamani/PersianAntigravityIDE/main/setup.ps1 | iex
```

> **نکته:** پس از اتمام نصب، محیط **Antigravity IDE** را یک‌بار ببندید و مجدداً باز کنید تا تغییرات بصری اعمال شوند.

---

## 💻 اجرای دستی از طریق سورس (Local Clone)

در صورت تمایل به اجرای محلی یا بررسی کدها قبل از نصب:

```bash
git clone https://github.com/mehdichamani/PersianAntigravityIDE.git ~/projects/PersianAntigravityIDE
cd ~/projects/PersianAntigravityIDE
```

### در لینوکس و مک (`setup.sh`)

```bash
# بررسی وضعیت فعلی نصب
./setup.sh status

# اجرای فرآیند نصب و اعمال پچ‌ها
./setup.sh install

# حذف کامل پچ‌ها و بازگردانی وضعیت به نسخه اصلی
./setup.sh uninstall
```

> 💡 *در لینوکس، اسکریپت تنها برای ذخیره فایل‌ها در دایرکتوری `/opt/antigravity-ide/` از شما دسترسی `sudo` خواهد خواست.*

### در ویندوز (`setup.ps1`)

```powershell
# بررسی وضعیت فعلی
pwsh -File ./setup.ps1 -Status

# نصب و اعمال پچ‌ها
pwsh -File ./setup.ps1 -Install

# حذف و بازگردانی فایل‌های اصلی
pwsh -File ./setup.ps1 -Uninstall
```

---

## 📁 ساختار مخزن

```text
PersianAntigravityIDE/
├── .gitignore
├── LICENSE                          # مجوز نرم‌افزار (MIT)
├── README.md                        # مستندات فارسی پروژه
├── README.en.md                     # مستندات انگلیسی پروژه
├── setup.sh                         # اسکریپت نصب و مدیریت لینوکس و مک
├── setup.ps1                        # اسکریپت نصب و مدیریت ویندوز (PowerShell)
├── styles/
│   ├── antigravity-chat-rtl.css     # استایل‌های شیک پنل چت و صفحات آرتیفکت
│   └── markdown-rtl.css             # استایل‌های پیش‌نمایش فایل‌های Markdown
└── scripts/
    └── antigravity-chat-rtl.js      # اسکریپت پویای تشخیص کاراکترهای راست‌به‌چپ
```

---

## ⚙️ سازوکار فنی (Under the Hood)

1. **تزریق به Workbench:** اسکریپت‌های نصب فایل‌های `antigravity-chat-rtl.css` و `antigravity-chat-rtl.js` را به فایل اصلی `out/vs/code/electron-browser/workbench/workbench.html` اضافه می‌کنند.
2. **رصد تغییرات DOM با MutationObserver:** اسکریپت جاوااسکریپت تغییرات المان‌های پنل چت را زیر نظر می‌گیرد. هر پاراگراف یا متنی که حاوی کاراکترهای یونیکد فارسی یا عربی (`[\u0600-\u06FF...]`) باشد، کلاس `.antigravity-is-rtl` را دریافت می‌کند.
3. **تفکیک هوشمند کدها:** استایل‌های CSS به صورت صریح بلوک‌های کدهای درون‌خطی و چندخطی (`code` و `pre`) را از تغییر جهت مستثنی کرده و جهت `ltr` آن‌ها را تضمین می‌کنند.
4. **حذف اخطار چک‌سام:** محیط VS Code و فورک‌های الکترونی آن به صورت پیش‌فرض کدهای دستکاری‌شده را با مقایسه هش در `product.json` شناسایی کرده و نوار هشدار نمایش می‌دهند. اسکریپت نصب با حذف امن کلید هش `workbench.html`، از بروز هرگونه اخطار جلوگیری به عمل می‌آورد.
5. **یکپارچه‌سازی مارک‌داون:** فایل `markdown-rtl.css` به تنظیمات کاربری `settings.json` در کلید `markdown.styles` معرفی می‌شود تا پیش‌نمایش فایل‌های مستندات نیز راست‌چین شوند.

---

## 🔤 پیش‌نیاز: نصب فونت وزیرمتن

برای داشتن بهترین تجربه بصری، پیشنهاد می‌شود فونت محبوب **وزیرمتن (Vazirmatn)** را روی سیستم خود نصب داشته باشید:

- **آرچ لینوکس (Arch / Omarchy Linux):**
  ```bash
  yay -S --needed ttf-vazirmatn
  ```
- **اوبونتو و دبیان (Ubuntu / Debian):**
  ```bash
  sudo apt install fonts-vazirmatn
  ```
- **ویندوز و مک (Windows & macOS):**
  دانلود و نصب مستقیم از صفحه [Google Fonts - Vazirmatn](https://fonts.google.com/specimen/Vazirmatn) یا صفحه گیت‌هاب رسمی صابر راستی‌کردار.

---

## ❓ پرسش‌های متداول (FAQ)

<details>
<summary><b>آیا با آپدیت شدن Antigravity IDE این تغییرات پاک می‌شوند؟</b></summary>
بله؛ هر بار که نسخه جدیدی از Antigravity IDE منتشر و نصب شود، فایل‌های Workbench به حالت پیش‌فرض بازمی‌گردند. در این حالت کافی است یک‌بار دیگر دستور نصب سریع تک‌خطی را اجرا کنید.
</details>

<details>
<summary><b>آیا این اسکریپت با افزونه‌های دیگر تداخل دارد؟</b></summary>
خیر؛ از آنجا که این راهکار متکی بر هیچ اکستنشن اضافی در VS Code نبوده و فقط استایل‌های کلاس‌های اختصاصی پنل Antigravity را هدف قرار می‌دهد، هیچ‌گونه تداخلی ایجاد نمی‌کند.
</details>

<details>
<summary><b>چگونه به نسخه اولیه برگردم؟</b></summary>
کافی است دستور حذف را اجرا کنید (`./setup.sh uninstall` در لینوکس یا `pwsh -File ./setup.ps1 -Uninstall` در ویندوز). اسکریپت نسخه‌های بکاپ `.bak` را بازیابی می‌کند.
</details>

---

## 📄 مجوز (License)

این پروژه تحت مجوز متن‌باز [MIT License](LICENSE) منتشر شده است و استفاده شخصی و تجاری از آن آزاد است.

توسعه‌یافته با ❤️ توسط [مهدی چمنی (Mehdi Chamani)](https://github.com/mehdichamani).

</div>
