import os

# the short licence text can be found in the NOTICE file
NOTICE_FILE = "NOTICE"

# the licence headers for different file types
# assign the proper comment pattern align with extension, please.
LICENSE_HEADERS = {
    ".sql": "/*\n{}\n*/\n\n",
    ".xml": "<!--\n{}\n-->\n\n",
    ".dtd": "<!--\n{}\n-->\n\n",
    ".yml": "#\n{}\n#\n\n",
    ".yaml": "#\n{}\n#\n\n",
    ".sh": "#\n{}\n#\n\n"
}

# excluded directories
# put here the directories you want to exclude from the process.
EXCLUDED_DIRS = {'.git','.github'}

def read_notice_file():
    """Beolvassa a NOTICE fájl tartalmát."""
    if not os.path.exists(NOTICE_FILE):
        raise FileNotFoundError(f"The {NOTICE_FILE} cannot be found in the project root.")
    
    with open(NOTICE_FILE, 'r', encoding='utf-8') as f:
        return f.read().strip()

def process_file(filepath, notice_content):
    """It adds a licence header to a file if it doesn't already have one."""
    ext = os.path.splitext(filepath)[1].lower()
    if ext not in LICENSE_HEADERS:
        return
    
    with open(filepath, 'r+', encoding='utf-8') as f:
        content = f.read()
        header = LICENSE_HEADERS[ext].format(notice_content)
        
        # Let's add the header if it's not already there
        if not content.startswith(header):
            f.seek(0)
            f.write(header + content)
            print(f"Added header to {filepath}")

def main():
    try:
        # It reads the content of the NOTICE file
        notice_content = read_notice_file()
        
        # It loops through the project files
        for root, dirs, files in os.walk('.'):
            dirs[:] = [d for d in dirs if d not in EXCLUDED_DIRS]
            for file in files:
                if any(file.endswith(ext) for ext in LICENSE_HEADERS):
                    process_file(os.path.join(root, file), notice_content)
    except FileNotFoundError as e:
        print(e)
        exit(1)

if __name__ == "__main__":
    main()