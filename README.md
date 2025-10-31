# 🧩 npm Package Updater

A simple, interactive Bash script to **check, list, and update outdated npm packages** — with colorful output, version distinction (major/minor/patch), and optional exclusions.

---

## 🚀 Features

- ✅ Detects outdated npm dependencies using `npm outdated`  
- 🎨 Color-coded output for better readability  
- ⚠️ Highlights **major** updates separately from **minor/patch** ones  
- ⚙️ Allows excluding specific packages via `.npm-update-exclude` file  
- 🧠 Automatically retries failed updates with `--force`  
- 🧩 Interactive confirmation before updating packages  

---

## 📦 Requirements

Make sure you have these installed before running the script:

- [Node.js & npm](https://nodejs.org/)  
- [jq](https://stedolan.github.io/jq/) — for parsing JSON output  

To check:
```bash
npm -v
jq --version
```

---

## 🧰 Installation

Clone the repository or copy the script to your project directory:

```bash
git clone https://github.com/aliazmoodehvaldi/auto-npm-upgrade.git
mv ./auto-npm-upgrade/script.sh ./
chmod +x script.sh
```

---

## 📝 Usage

Run the script from your project root:

```bash
./script.sh
```

The script will:
1. Check for outdated packages  
2. Show which ones have major updates  
3. List minor and patch updates  
4. Ask if you want to proceed with updating  
5. Update the selected packages one by one  

---

## 🧾 Example Output

```bash
🔍 Checking for outdated npm packages...

⚠️  Packages with MAJOR updates available:
Package                        Current         Latest
------------------------------ --------------- ---------------
eslint                         7.32.0          8.5.0

📦 Packages with minor/patch updates available:
Package                        Current         Latest
------------------------------ --------------- ---------------
lodash                         4.17.20         4.17.21

❓ Do you want to update these packages? (y/n): y
⬆️  Updating packages...
✅ Successfully updated lodash

🎉 Update finished!
```

---

## 🚫 Excluding Packages

To skip certain packages during updates, create a `.npm-update-exclude` file in your project root and list one package per line:

```
react
webpack
eslint
```

The script will show excluded packages before updating.

---

## 🧪 Notes

- The script only updates **dependencies** listed in your `package.json`.  
- It **won’t automatically update** major versions — you’ll need to do those manually after testing.  
- If an update fails, the script retries once with `--force`.  

---

## 💡 Tips

- Run this script regularly to keep dependencies up-to-date.
- Combine it with a CI pipeline or pre-release workflow for automated checks.

---

## 🧑‍💻 Author

Created with ❤️ by Ali Azmoodeh Valdi  
📧 Contact: [treeroot.ir@example.com]  
🌐 GitHub: [https://github.com/aliazmoodehvaldi](https://github.com/aliazmoodehvaldi)

---

## 🪪 License

MIT License — free to use and modify.