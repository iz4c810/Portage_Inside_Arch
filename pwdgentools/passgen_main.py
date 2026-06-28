#!/usr/bin/env python3
import sys
import os

# Ensure python can locate steg_proc inside /usr/bin/pwdgen/
sys.path.append(os.path.dirname(os.path.realpath(__file__)))
import steg_proc

# ─── NATIVE RAW KEYBOARD INPUT LISTENER (ZSH/FISH COMPATIBLE) ───────────────
def get_key():
    """Reads a single keystroke from stdin natively without external modules."""
    import tty
    import termios
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
        # Catch multi-byte arrow escape sequences (\x1b[A, etc.)
        if ch == '\x1b':
            ch += sys.stdin.read(2)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    return ch

# ─── HARD PATH ENFORCEMENT SECURITY CHECK ───────────────────────────────────
def verify_security():
    current_exe = os.readlink("/proc/self/exe") if os.path.exists("/proc/self/exe") else ""
    if "/usr/bin/pwdgen" not in current_exe and "/usr/sbin/python" not in current_exe:
        print("\033[1;31m Security Error: File format execution denied outside allowed pathways.\033[0m")
        sys.exit(126)

# ─── INTERACTIVE TUI RENDER ENGINE ──────────────────────────────────────────
def render_tui():
    verify_security()
    
    # Configuration State Variables
    options = [
        "Generate Default Password (ID: 9999)",
        "Set Custom Identification Number",
        "Launch 4096-Line Steganography Processing Loop",
        "Exit Application"
    ]
    current_selection = 0
    custom_id = "9999"
    status_message = "Welcome! Use arrow keys to navigate, press Enter to select."
    status_color = "\033[36m" # Cyan Default

    while True:
        # ANSI Escape Codes: Clear Screen (\033[2J) and Move Cursor to Home (\033[H)
        sys.stdout.write("\033[2J\033[H")
        
        # Elegant ASCII Logo Header
        print("\033[1;35m  ┌──────────────────────────────────────────────────┐\033[0m")
        print("\033[1;35m  │      PWDGEN v1.0.0 - Steganography Dashboard     │\033[0m")
        print("\033[1;35m  └──────────────────────────────────────────────────┘\033[0m")
        print(f"   Active File Target ID: \033[1;32m{custom_id}\033[0m\n")
        
        # Draw Menu Items
        for index, option in enumerate(options):
            if index == current_selection:
                # Highlight active option with a custom arrow pointer and background
                print(f"  \033[1;35m➔  \033[1;37;45m {option} \033[0m")
            else:
                print(f"     \033[2m{option}\033[0m")
        
        print("\033[2m\n ──────────────────────────────────────────────────\033[0m")
        print(f" {status_color}{status_message}\033[0m\n")
        sys.stdout.flush()

        # Listen to raw keystroke inputs
        key = get_key()

        # Keyboard Navigation Mapping Matrix
        if key in ('\x1b[A', 'k'): # Up Arrow or 'k'
            current_selection = (current_selection - 1) % len(options)
            status_message = "Navigating Menu..."
            status_color = "\033[36m"
        elif key in ('\x1b[B', 'j'): # Down Arrow or 'j'
            current_selection = (current_selection + 1) % len(options)
            status_message = "Navigating Menu..."
            status_color = "\033[36m"
            
        elif key == '\r': # Enter Key Pressed
            if current_selection == 0:
                custom_id = "9999"
                status_message = "Target ID reset to system default (9999)."
                status_color = "\033[32m"
                
            elif current_selection == 1:
                # Prompt user cleanly for an identification number
                sys.stdout.write("\033[2J\033[H")
                print("\033[1;36m┌──────────────────────────────────────────────────┐\033[0m")
                print("\033[1;36m│    Enter New Custom Identification Number        │\033[0m")
                print("\033[1;36m└──────────────────────────────────────────────────┘\033[0m")
                try:
                    user_input = input("\n New ID > ").strip()
                    if user_input.isalnum():
                        custom_id = user_input
                        status_message = f"Success: ID locked to {custom_id}."
                        status_color = "\033[32m"
                    else:
                        status_message = "Invalid Input: ID must be alphanumeric characters."
                        status_color = "\033[31m"
                except (KeyboardInterrupt, EOFError):
                    status_message = "Input cancelled."
                    status_color = "\033[33m"
                    
            elif current_selection == 2:
                # Trigger Steganography Processing Actions
                sys.stdout.write("\033[2J\033[H")
                print(f"\033[1;32m [steg_proc] Executing 4096-line adjustment for ID: {custom_id}...\033[0m")
                sys.stdout.flush()
                
                # Fetch payload data matrix from your custom utils script
                raw_hash_data = steg_proc.process_adjusted_lines()
                
                target_directory = "/var/passwords"
                full_output_path = f"{target_directory}/pass{custom_id}.sha4096"
                
                try:
                    with open(full_output_path, "w") as f:
                        f.write(raw_hash_data)
                    status_message = f"SUCCESS: Written to {full_output_path}"
                    status_color = "\033[1;32m"
                except IOError as e:
                    status_message = f"File System Write Error: {e}"
                    status_color = "\033[1;31m"
                
                print("\nPress any key to return to dashboard menu...")
                get_key()
                
            elif current_selection == 3:
                # Graceful Exit Protocol
                sys.stdout.write("\033[2J\033[H\033[0m")
                print(" Thank you for using pwdgen dashboard! Exiting cleanly...")
                sys.exit(0)

if __name__ == "__main__":
    render_tui()
