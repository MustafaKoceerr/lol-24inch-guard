# LoL 24-Inch Guard (`2276×1280` on 27" 2K Monitors)

**[🇹🇷 Türkçe](#-türkçe)** | **[🇬🇧 English](#-english)**

---

## 🇹🇷 Türkçe

**LoL 24-Inch Guard**, 27 inç 2K (`2560×1440`) monitör kullanan ancak **League of Legends** oynarken görüntünün bulanıklaşmadan (**1:1 piksel eşleme** ile) ekranın tam ortasında **gerçek fiziksel 24 inç (`2276×1280`)** boyutunda çalışmasını ve etrafındaki boşlukların siyah kalmasını sağlayan hafif bir Windows aracıdır.

### Neden `2276×1280`?
27 inç `2560×1440` bir monitörde pikseller birebir (ölçeklendirmesiz) kullanıldığında:
- Standart `1920×1080` çözünürlük ekranda fiziksel olarak **20.25 inç** gibi çok küçük bir alan kaplar.
- Tam **24 inç** fiziksel diyagonal boyut için gereken 16:9 çözünürlük ise:
  $$\frac{24}{27} \times 2560 = \mathbf{2276\text{ px}}, \quad \frac{24}{27} \times 1440 = \mathbf{1280\text{ px}}$$
  olarak hesaplanır. Böylece hem 2K monitörünüzün doğal piksel keskinliği korunur hem de espor standartlarındaki 24 inç görüş alanı elde edilir.

### Özellikler
- **Sadece LoL Maç Ekranında Aktif Olur:** Masaüstünüz, tarayıcınız, diğer oyunlarınız ve LoL İstemcisi (`LeagueClientUx.exe`) 27 inç `2560×1440` kalır. Yalnızca maç başladığında (`League of Legends.exe`) devreye girer.
- **Tam Siyah Çerçeve (Görev Çubuğu Dahil):** Oyun penceresini ekranın tam merkezine (`X=142, Y=80`) yerleştirir ve arka planı görev çubuğu dahil saf siyah (`#000000`) bir katmanla kapatır.
- **Kusursuz Kamera Kaydırma (`ClipCursor`):** Oyun odaktayken fare imlecini Win32 `ClipCursor` API'si ile `2276×1280` oyun alanına kilitler; dört kenarda da kamera kaydırma (edge-panning) tam ekran modundaki gibi çalışır.
- **Ekran Kararmadan Anında `Alt+Tab`:** Monitör çözünürlüğü değiştirilmediği için `Alt+Tab` yaptığınız anda siyah çerçeve gizlenir ve saliseler içinde 27 inç 2K masaüstünüze dönersiniz.
- **Sıfır Kaynak Tüketimi:** C# / Win32 API tabanlıdır; harici program (AutoHotkey vb.) gerektirmez.

### Kurulum
1. Repoyu indirin veya klonlayın:
   ```powershell
   git clone https://github.com/MustafaKoceerr/lol-24inch-guard.git
   ```
2. **`Install-LoL24InchGuard.bat`** dosyasına çift tıklayın.
   - Mevcut `game.cfg` dosyanızın yedeğini (`game.cfg.bak`) alır ve çözünürlüğü `2276×1280` (Çerçevesiz) olarak ayarlar.
   - Bilgisayar açılışında sessizce başlaması için `LoL24InchGuard` zamanlanmış görevini kaydeder ve servisi başlatır.

### Kaldırma / Orijinal Ayarlara Dönme
- **`Stop-LoL24InchGuard.bat`** dosyasına çift tıklamanız yeterlidir. Arka plan servisi kaldırılır ve `game.cfg.bak` yedeğiniz geri yüklenerek LoL tekrar 27 inç `2560×1440` moduna döner.

---

## 🇬🇧 English

**LoL 24-Inch Guard** is a lightweight Windows utility for 27-inch 2K (`2560×1440`) monitor users who want **League of Legends** to run in an **exact physical 24-inch (`2276×1280`)** centered viewport with 1:1 pixel sharpness and pure black bars around the edges—**only while in a match**.

### Why `2276×1280`?
On a 27-inch `2560×1440` monitor with 1:1 unscaled pixels:
- Standard `1920×1080` only occupies **20.25 inches** diagonally.
- To get an exact **24.0-inch** physical 16:9 viewport with native pixel sharpness:
  $$\frac{24}{27} \times 2560 = \mathbf{2276\text{ px}}, \quad \frac{24}{27} \times 1440 = \mathbf{1280\text{ px}}$$

### Features
- **Only Affects Active LoL Matches:** Your Windows desktop, browser, other games, and the Riot/LoL Lobby Client remain at full 27-inch `2560×1440`. The guard activates strictly when a match starts (`League of Legends.exe`).
- **True Black Bars (Covers Taskbar):** Centers the borderless game window at `(142, 80)` and places a non-activating pure black (`#000000`) overlay directly behind the game window, covering the desktop and taskbar.
- **Native Camera Edge-Panning (`ClipCursor`):** Automatically locks the mouse cursor to the `2276×1280` game bounds while League of Legends is focused so camera edge-panning works seamlessly on all four sides.
- **Instant `Alt+Tab` (No Display Mode Switch):** Pressing `Alt+Tab` immediately hides the black overlay and releases the cursor lock, returning you to your full 27-inch 1440p desktop with zero monitor blackouts.
- **Zero Dependencies:** Uses built-in Windows PowerShell + inline C# Win32 P/Invoke (`user32.dll`).

### Installation
1. Clone or download this repository:
   ```powershell
   git clone https://github.com/MustafaKoceerr/lol-24inch-guard.git
   ```
2. Double-click **`Install-LoL24InchGuard.bat`**.
   - Backs up your League of Legends `game.cfg` to `game.cfg.bak` and configures `2276×1280` borderless mode.
   - Registers and starts the silent background task (`LoL24InchGuard`) at Windows logon.

### Uninstallation / Restore 27" Fullscreen
- Double-click **`Stop-LoL24InchGuard.bat`** at any time to stop/unregister the background task and restore your original `game.cfg`.

---

## License
Released under the [MIT License](LICENSE).
