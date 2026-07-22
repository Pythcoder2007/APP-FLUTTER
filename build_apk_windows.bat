"""
Sports Emporium Manager
A desktop billing, inventory and revenue tracking app for a sports goods shop.

Run:  python main.py
"""
import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime
import db

APP_TITLE = "Shri Shakra Sports"

# ---------------- Palette (Dark & Orange Theme) ----------------
BG_PAGE = "#0f141e"           
SIDEBAR_BG = "#0b0f17"        
SIDEBAR_ITEM_HOVER = "#151b29" 
SIDEBAR_ITEM_ACTIVE = "#1a212d" 
SIDEBAR_TEXT = "#8a94a6"      
SIDEBAR_TEXT_ACTIVE = "#ff5722" 

ACCENT = "#ff5722"            
ACCENT_HOVER = "#e64a19"      
GREEN = "#00e676"             
RED = "#ff3d00"               
RED_LIGHT = "#3b1a1a"         
TEXT_MAIN = "#ffffff"         
TEXT_MUTED = "#8a94a6"        
CARD_BG = "#1a212d"           
CARD_BORDER = "#252d3d"       
ROW_ALT = "#161c26"           

FONT = ("Segoe UI", 10)
FONT_SM = ("Segoe UI", 9)
FONT_BOLD = ("Segoe UI", 10, "bold")
FONT_H1 = ("Segoe UI", 19, "bold")
FONT_H2 = ("Segoe UI", 12, "bold")
FONT_CARD_VAL = ("Segoe UI", 21, "bold")
FONT_NAV = ("Segoe UI", 11)

NAV_ITEMS = [
    ("dashboard", "🏠", "Dashboard"),
    ("inventory", "📦", "Inventory"),
    ("customers", "👥", "Customers"),
    ("billing", "🧾", "Billing"),
    ("history", "📁", "History"),
    ("reports", "📊", "Revenue & Profit"),
    ("settings", "⚙", "Settings"),
]


def seed_dummy_inventory():
    prods = db.get_all_products()
    if not prods:
        dummy_items = [
            ("BAT-001", "MRF Grand Edition Cricket Bat", "Cricket", 12000.0, 18000.0, 10, 3),
            ("BAL-002", "Nivia Storm Football", "Football", 600.0, 999.0, 25, 5),
            ("RAC-003", "Yonex Arcsaber Badminton Racket", "Badminton", 3500.0, 5500.0, 12, 4),
            ("SHP-004", "Nike Air Zoom Running Shoes", "Footwear", 4500.0, 7999.0, 8, 2),
            ("BAL-005", "Cosco Pro Basketball", "Basketball", 800.0, 1400.0, 15, 4),
            ("ACC-006", "SG Club Cricket Batting Gloves", "Cricket", 450.0, 850.0, 20, 5),
            ("ACC-007", "Nivia Shin Guards", "Football", 200.0, 399.0, 30, 6),
            ("ACC-008", "Stag Table Tennis Racket Set", "Table Tennis", 700.0, 1200.0, 14, 3),
            ("EQP-009", "Strauss Agility Training Ladder", "Fitness", 500.0, 950.0, 10, 2),
            ("BAG-010", "Puma Kit Gym Duffel Bag", "Accessories", 1100.0, 1999.0, 18, 4)
        ]
        for item in dummy_items:
            db.add_product(*item)


def currency():
    return db.get_setting("currency_symbol", "Rs.")


def fmt_money(v):
    try:
        return f"{currency()} {float(v):,.2f}"
    except Exception:
        return f"{currency()} 0.00"


def make_button(parent, text, command, bg=ACCENT, hover=ACCENT_HOVER, fg="white",
                font=FONT_BOLD, padx=16, pady=9, icon=None):
    label = f"{icon}  {text}" if icon else text
    btn = tk.Button(parent, text=label, command=command, bg=bg, fg=fg, font=font,
                     relief="flat", bd=0, padx=padx, pady=pady, cursor="hand2",
                     activebackground=hover, activeforeground=fg)
    btn.bind("<Enter>", lambda e: btn.config(bg=hover))
    btn.bind("<Leave>", lambda e: btn.config(bg=bg))
    return btn


def make_entry(parent, textvariable=None, width=None, font=FONT):
    e = tk.Entry(parent, textvariable=textvariable, font=font, relief="flat",
                 bg="#121824", fg=TEXT_MAIN, insertbackground=TEXT_MAIN,
                 highlightthickness=1, highlightbackground=CARD_BORDER, highlightcolor=ACCENT)
    if width:
        e.config(width=width)
    e.config(bd=6)
    return e


def style_treeview(tree):
    tree.tag_configure("odd", background=ROW_ALT)
    tree.tag_configure("even", background=CARD_BG)
    tree.tag_configure("low", background=RED_LIGHT, foreground=RED)


def add_scrollbar(parent, tree):
    sb = ttk.Scrollbar(parent, orient="vertical", command=tree.yview)
    tree.configure(yscrollcommand=sb.set)
    sb.pack(side="right", fill="y")


class StatCard(tk.Frame):
    def __init__(self, master, title, value, subtext="", bg_color=CARD_BG, fg_color=TEXT_MAIN, is_orange=False, **kw):
        super().__init__(master, bg=bg_color, highlightbackground=CARD_BORDER if not is_orange else ACCENT, highlightthickness=1, **kw)
        stripe = tk.Frame(self, bg=ACCENT if is_orange else CARD_BORDER, width=4)
        stripe.pack(side="left", fill="y")
        body = tk.Frame(self, bg=bg_color)
        body.pack(side="left", fill="both", expand=True, padx=16, pady=14)
        top = tk.Frame(body, bg=bg_color)
        top.pack(anchor="w", fill="x")
        tk.Label(top, text=title, bg=bg_color, fg="#ffffff" if is_orange else TEXT_MUTED, font=FONT).pack(side="left")
        
        self.value_lbl = tk.Label(body, text=value, bg=bg_color, fg=fg_color, font=FONT_CARD_VAL)
        self.value_lbl.pack(anchor="w", pady=(6, 0))
        self.sub_lbl = tk.Label(body, text=subtext, bg=bg_color, fg="#ffffff" if is_orange else TEXT_MUTED, font=FONT_SM)
        self.sub_lbl.pack(anchor="w", pady=(2, 0))

    def set_data(self, value, subtext=None):
        self.value_lbl.config(text=value)
        if subtext is not None:
            self.sub_lbl.config(text=subtext)


class SectionHeader(tk.Frame):
    def __init__(self, master, title, subtitle=None, button_text=None, button_command=None,
                 button_icon=None, **kw):
        super().__init__(master, bg=BG_PAGE, **kw)
        left = tk.Frame(self, bg=BG_PAGE)
        left.pack(side="left")
        tk.Label(left, text=title, font=FONT_H1, bg=BG_PAGE, fg=TEXT_MAIN).pack(anchor="w")
        if subtitle:
            tk.Label(left, text=subtitle, font=FONT_SM, bg=BG_PAGE, fg=TEXT_MUTED).pack(anchor="w")
        if button_text and button_command:
            btn = make_button(self, button_text, button_command, icon=button_icon)
            btn.pack(side="right", anchor="e")


class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title(APP_TITLE)
        self.geometry("1240x760")
        self.configure(bg=BG_PAGE)
        self.minsize(1040, 640)

        self._setup_styles()
        db.init_db()
        seed_dummy_inventory()
        
        self.cart = []
        self.nav_buttons = {}
        self.current_page = "dashboard"
        
        self.active_inv_category = None
        self.inv_cat_buttons = {}
        self.last_completed_sale_id = None

        self._build_sidebar()
        self._build_content_container()

        self.build_dashboard()
        self.build_billing()
        self.build_inventory()
        self.build_customers()
        self.build_history()
        self.build_reports()
        self.build_settings()

        self.show_page("dashboard")
        self._build_login_screen()

        self.protocol("WM_DELETE_WINDOW", self.destroy)

    def _build_login_screen(self):
        self.login_frame = tk.Frame(self, bg=BG_PAGE)
        self.login_frame.place(relx=0, rely=0, relwidth=1, relheight=1)

        center_card = tk.Frame(self.login_frame, bg=CARD_BG, highlightbackground=ACCENT, highlightthickness=1)
        center_card.place(relx=0.5, rely=0.5, anchor="center", width=700, height=380)

        left = tk.Frame(center_card, bg=CARD_BG)
        left.pack(side="left", fill="both", expand=True, padx=40, pady=40)

        tk.Label(left, text="WELCOME BACK", font=FONT_SM, bg=CARD_BG, fg=ACCENT).pack(anchor="w")
        tk.Label(left, text="Shri Shakra Sports", font=FONT_H1, bg=CARD_BG, fg=TEXT_MAIN).pack(anchor="w", pady=(0, 20))

        tk.Label(left, text="Password (Default: 12345678)", font=FONT_SM, bg=CARD_BG, fg=TEXT_MUTED).pack(anchor="w")
        self.pw_entry = tk.Entry(left, show="*", font=FONT, width=28, bg="#121824", fg=TEXT_MAIN, bd=6, relief="flat", insertbackground=TEXT_MAIN)
        self.pw_entry.pack(anchor="w", pady=(6, 20))
        self.pw_entry.bind("<Return>", lambda e: self._check_password())

        self.unlock_btn = make_button(left, "Unlock System", self._check_password, padx=20, pady=8)
        self.unlock_btn.pack(anchor="w")

        right = tk.Frame(center_card, bg=ACCENT, width=220)
        right.pack(side="right", fill="y")
        right.pack_propagate(False)
        
        r_inner = tk.Frame(right, bg=ACCENT)
        r_inner.place(relx=0.5, rely=0.5, anchor="center")
        tk.Label(r_inner, text="⚡", bg=ACCENT, fg="#ffffff", font=("Segoe UI", 48)).pack()
        tk.Label(r_inner, text="SECURE POS", bg=ACCENT, fg="#ffffff", font=FONT_BOLD).pack(pady=(4, 0))

        self.pw_entry.focus_set()

    def _check_password(self):
        if self.pw_entry.get() == "12345678":
            self.unlock_btn.config(text="Access Granted", bg=GREEN)
            self.after(500, self.login_frame.destroy)
        else:
            messagebox.showerror("Access Denied", "Incorrect Password")
            self.pw_entry.delete(0, tk.END)

    def _setup_styles(self):
        style = ttk.Style(self)
        try:
            style.theme_use("clam")
        except Exception:
            pass
        style.configure("Treeview", font=FONT, rowheight=28, background=CARD_BG,
                         fieldbackground=CARD_BG, foreground=TEXT_MAIN, borderwidth=0)
        style.configure("Treeview.Heading", font=FONT_BOLD, background="#121824",
                         foreground=TEXT_MUTED, relief="flat", padding=6)
        style.map("Treeview.Heading", background=[("active", "#1a212d")])
        style.map("Treeview", background=[("selected", "#252d3d")],
                  foreground=[("selected", TEXT_MAIN)])
        style.configure("TCombobox", font=FONT, fieldbackground="#121824", background="#121824", foreground=TEXT_MAIN)
        style.configure("Vertical.TScrollbar", background="#252d3d", troughcolor=BG_PAGE, borderwidth=0)

    # ---------------- SIDEBAR ----------------
    def _build_sidebar(self):
        sidebar = tk.Frame(self, bg=SIDEBAR_BG, width=215)
        sidebar.pack(side="left", fill="y")
        sidebar.pack_propagate(False)

        shop_name = db.get_setting("shop_name", "Shri Shakra Sports")
        logo_frame = tk.Frame(sidebar, bg=SIDEBAR_BG)
        logo_frame.pack(fill="x", pady=(22, 18), padx=18)
        tk.Label(logo_frame, text="⚡", bg=ACCENT, fg="white", font=("Segoe UI", 16, "bold"), width=2, height=1).pack(anchor="w")
        self.sidebar_shop_lbl = tk.Label(logo_frame, text=shop_name, bg=SIDEBAR_BG, fg="white",
                                          font=("Segoe UI", 13, "bold"), wraplength=170, justify="left")
        self.sidebar_shop_lbl.pack(anchor="w", pady=(8, 0))

        sep = tk.Frame(sidebar, bg="#1a212d", height=1)
        sep.pack(fill="x", padx=18, pady=(0, 10))

        self.nav_frame = tk.Frame(sidebar, bg=SIDEBAR_BG)
        self.nav_frame.pack(fill="x")

        for key, icon, label in NAV_ITEMS:
            self._add_nav_item(key, icon, label)

        tk.Frame(sidebar, bg=SIDEBAR_BG).pack(fill="both", expand=True)
        self.sidebar_clock = tk.Label(sidebar, text="", bg=SIDEBAR_BG, fg=TEXT_MUTED, font=FONT_SM)
        self.sidebar_clock.pack(side="bottom", pady=14)
        self._tick_clock()

    def _tick_clock(self):
        self.sidebar_clock.config(text=datetime.now().strftime("%d %b %Y\n%I:%M %p"))
        self.after(30000, self._tick_clock)

    def _add_nav_item(self, key, icon, label):
        row = tk.Frame(self.nav_frame, bg=SIDEBAR_BG, cursor="hand2")
        row.pack(fill="x", padx=10, pady=2)
        indicator = tk.Frame(row, bg=SIDEBAR_BG, width=4)
        indicator.pack(side="left", fill="y")
        inner = tk.Frame(row, bg=SIDEBAR_BG)
        inner.pack(side="left", fill="both", expand=True, ipady=9, padx=6)
        icon_lbl = tk.Label(inner, text=icon, bg=SIDEBAR_BG, fg=SIDEBAR_TEXT, font=("Segoe UI", 12))
        icon_lbl.pack(side="left", padx=(6, 10))
        text_lbl = tk.Label(inner, text=label, bg=SIDEBAR_BG, fg=SIDEBAR_TEXT, font=FONT_NAV)
        text_lbl.pack(side="left")

        widgets = [row, indicator, inner, icon_lbl, text_lbl]
        for w in widgets:
            w.bind("<Button-1>", lambda e, k=key: self.show_page(k))
            if key != "active":
                w.bind("<Enter>", lambda e, k=key: self._nav_hover(k, True))
                w.bind("<Leave>", lambda e, k=key: self._nav_hover(k, False))

        self.nav_buttons[key] = {
            "row": row, "indicator": indicator, "inner": inner,
            "icon": icon_lbl, "text": text_lbl
        }

    def _nav_hover(self, key, entering):
        if self.current_page == key:
            return
        widgets = self.nav_buttons[key]
        bg = SIDEBAR_ITEM_HOVER if entering else SIDEBAR_BG
        widgets["row"].config(bg=bg)
        widgets["inner"].config(bg=bg)
        widgets["icon"].config(bg=bg)
        widgets["text"].config(bg=bg)

    def _set_nav_active(self, active_key):
        for key, widgets in self.nav_buttons.items():
            is_active = key == active_key
            bg = SIDEBAR_ITEM_ACTIVE if is_active else SIDEBAR_BG
            fg = "#ffffff" if is_active else SIDEBAR_TEXT
            widgets["row"].config(bg=bg)
            widgets["indicator"].config(bg=ACCENT if is_active else SIDEBAR_BG)
            widgets["inner"].config(bg=bg)
            widgets["icon"].config(bg=bg, fg=fg)
            widgets["text"].config(bg=bg, fg=fg, font=(FONT_NAV[0], FONT_NAV[1], "bold" if is_active else "normal"))

    # ---------------- CONTENT CONTAINER ----------------
    def _build_content_container(self):
        outer = tk.Frame(self, bg=BG_PAGE)
        outer.pack(side="left", fill="both", expand=True)

        topbar = tk.Frame(outer, bg=CARD_BG, height=54, highlightbackground=CARD_BORDER, highlightthickness=1)
        topbar.pack(fill="x", side="top")
        topbar.pack_propagate(False)
        self.topbar_title = tk.Label(topbar, text="Dashboard", font=FONT_H2, bg=CARD_BG, fg=TEXT_MAIN)
        self.topbar_title.pack(side="left", padx=20)
        self.topbar_date = tk.Label(topbar, text=datetime.now().strftime("%A, %d %B %Y"),
                                     font=FONT_SM, bg=CARD_BG, fg=TEXT_MUTED)
        self.topbar_date.pack(side="right", padx=20)

        self.content = tk.Frame(outer, bg=BG_PAGE)
        self.content.pack(fill="both", expand=True)
        self.content.grid_rowconfigure(0, weight=1)
        self.content.grid_columnconfigure(0, weight=1)

        self.pages = {}
        for key, _, _ in NAV_ITEMS:
            frame = tk.Frame(self.content, bg=BG_PAGE)
            frame.grid(row=0, column=0, sticky="nsew")
            self.pages[key] = frame

        self.tab_dashboard = self.pages["dashboard"]
        self.tab_inventory = self.pages["inventory"]
        self.tab_customers = self.pages["customers"]
        self.tab_billing = self.pages["billing"]
        self.tab_history = self.pages["history"]
        self.tab_reports = self.pages["reports"]
        self.tab_settings = self.pages["settings"]

    def show_page(self, key):
        self.current_page = key
        self._set_nav_active(key)
        label_map = dict((k, l) for k, _, l in NAV_ITEMS)
        self.topbar_title.config(text=label_map[key])
        self.pages[key].tkraise()

        if key == "dashboard":
            self.refresh_dashboard()
        elif key == "inventory":
            self.refresh_inventory_categories()
            self.refresh_inventory()
        elif key == "customers":
            self.refresh_customers()
        elif key == "history":
            self.refresh_history()
        elif key == "reports":
            self.refresh_reports()
        elif key == "billing":
            self.refresh_product_list()

    def refresh_header(self):
        shop_name = db.get_setting("shop_name", "Shri Shakra Sports")
        self.sidebar_shop_lbl.config(text=shop_name)

    # ================= DASHBOARD =================
    def build_dashboard(self):
        f = self.tab_dashboard
        wrap = tk.Frame(f, bg=BG_PAGE)
        wrap.pack(fill="both", expand=True, padx=22, pady=18)

        SectionHeader(wrap, "Business Overview", "A quick look at how things are going today").pack(fill="x", pady=(0, 14))

        cards = tk.Frame(wrap, bg=BG_PAGE)
        cards.pack(fill="x")
        self.card_today = StatCard(cards, "Today's Revenue", fmt_money(0), "0 transactions", is_orange=True)
        self.card_month = StatCard(cards, "This Month's Revenue", fmt_money(0), "Revenue")
        self.card_year = StatCard(cards, "This Year's Revenue", fmt_money(0), "Revenue")
        self.card_lowstock = StatCard(cards, "Low Stock Items", "0", "Items below threshold")
        for i, c in enumerate([self.card_today, self.card_month, self.card_year, self.card_lowstock]):
            c.grid(row=0, column=i, padx=(0 if i == 0 else 10, 0), sticky="nsew")
            cards.grid_columnconfigure(i, weight=1)

        bottom = tk.Frame(wrap, bg=BG_PAGE)
        bottom.pack(fill="both", expand=True, pady=(18, 0))
        bottom.grid_columnconfigure(0, weight=1)
        bottom.grid_columnconfigure(1, weight=1)
        bottom.grid_rowconfigure(0, weight=1)

        left = tk.Frame(bottom, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        left.grid(row=0, column=0, sticky="nsew", padx=(0, 10))
        tk.Label(left, text="🧾  Recent Sales", font=FONT_H2, bg=CARD_BG, fg=TEXT_MAIN).pack(anchor="w", padx=14, pady=(12, 6))
        tree_wrap = tk.Frame(left, bg=CARD_BG)
        tree_wrap.pack(fill="both", expand=True, padx=14, pady=(0, 14))
        cols = ("invoice", "date", "total", "payment")
        self.recent_tree = ttk.Treeview(tree_wrap, columns=cols, show="headings", height=10)
        for c, t, w in zip(cols, ["Invoice", "Date", "Total", "Payment"], [100, 150, 100, 100]):
            self.recent_tree.heading(c, text=t)
            self.recent_tree.column(c, width=w, anchor="center")
        style_treeview(self.recent_tree)
        self.recent_tree.pack(side="left", fill="both", expand=True)
        add_scrollbar(tree_wrap, self.recent_tree)

        right = tk.Frame(bottom, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        right.grid(row=0, column=1, sticky="nsew", padx=(10, 0))
        tk.Label(right, text="⚠  Low Stock Alerts", font=FONT_H2, bg=CARD_BG, fg=TEXT_MAIN).pack(anchor="w", padx=14, pady=(12, 6))
        tree_wrap2 = tk.Frame(right, bg=CARD_BG)
        tree_wrap2.pack(fill="both", expand=True, padx=14, pady=(0, 14))
        cols2 = ("name", "qty", "threshold")
        self.lowstock_tree = ttk.Treeview(tree_wrap2, columns=cols2, show="headings", height=10)
        for c, t, w in zip(cols2, ["Product", "Qty Left", "Reorder At"], [180, 100, 100]):
            self.lowstock_tree.heading(c, text=t)
            self.lowstock_tree.column(c, width=w, anchor="center")
        style_treeview(self.lowstock_tree)
        self.lowstock_tree.pack(side="left", fill="both", expand=True)
        add_scrollbar(tree_wrap2, self.lowstock_tree)

        self.refresh_dashboard()

    def refresh_dashboard(self):
        t_total, t_cnt = db.revenue_today()
        m_total, m_cnt = db.revenue_this_month()
        y_total, y_cnt = db.revenue_this_year()
        low = db.get_low_stock_products()

        self.card_today.set_data(fmt_money(t_total), f"{t_cnt} transactions")
        self.card_month.set_data(fmt_money(m_total), "Revenue")
        self.card_year.set_data(fmt_money(y_total), "Revenue")
        self.card_lowstock.set_data(str(len(low)), "Items below threshold")

        for row in self.recent_tree.get_children():
            self.recent_tree.delete(row)
        for i, s in enumerate(db.get_recent_sales(15)):
            tag = "odd" if i % 2 else "even"
            self.recent_tree.insert("", "end", values=(s["invoice_no"], s["sale_date"][:16],
                                                         fmt_money(s["total"]), s["payment_method"]), tags=(tag,))

        for row in self.lowstock_tree.get_children():
            self.lowstock_tree.delete(row)
        for i, p in enumerate(low):
            self.lowstock_tree.insert("", "end", values=(p["name"], p["quantity"], p["low_stock_threshold"]),
                                       tags=("low",))

    # ================= BILLING =================
    def build_billing(self):
        f = self.tab_billing
        wrap = tk.Frame(f, bg=BG_PAGE)
        wrap.pack(fill="both", expand=True, padx=22, pady=18)
        wrap.grid_columnconfigure(0, weight=3)
        wrap.grid_columnconfigure(1, weight=2)
        wrap.grid_rowconfigure(0, weight=1)

        left = tk.Frame(wrap, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        left.grid(row=0, column=0, sticky="nsew", padx=(0, 10))

        search_row = tk.Frame(left, bg=CARD_BG)
        search_row.pack(fill="x", padx=16, pady=(16, 8))
        tk.Label(search_row, text="🔍", bg=CARD_BG, font=FONT).pack(side="left")
        self.bill_search_var = tk.StringVar()
        entry = make_entry(search_row, self.bill_search_var, width=34)
        entry.pack(side="left", padx=8, fill="x", expand=True)
        entry.bind("<KeyRelease>", lambda e: self.refresh_product_list())

        tree_wrap = tk.Frame(left, bg=CARD_BG)
        tree_wrap.pack(fill="both", expand=True, padx=16)
        cols = ("name", "category", "price", "stock")
        self.product_tree = ttk.Treeview(tree_wrap, columns=cols, show="headings", height=20)
        for c, t, w in zip(cols, ["Product", "Category", "Price", "In Stock"], [220, 130, 100, 90]):
            self.product_tree.heading(c, text=t)
            self.product_tree.column(c, width=w, anchor="center" if c != "name" else "w")
        style_treeview(self.product_tree)
        self.product_tree.pack(side="left", fill="both", expand=True)
        add_scrollbar(tree_wrap, self.product_tree)
        self.product_tree.bind("<Double-1>", lambda e: self.add_to_cart())

        add_row = tk.Frame(left, bg=CARD_BG)
        add_row.pack(fill="x", padx=16, pady=14)
        tk.Label(add_row, text="Qty:", bg=CARD_BG, fg=TEXT_MAIN, font=FONT).pack(side="left")
        self.qty_var = tk.StringVar(value="1")
        make_entry(add_row, self.qty_var, width=6).pack(side="left", padx=8)
        make_button(add_row, "Add to Cart", self.add_to_cart, icon="➕").pack(side="left", padx=10)
        tk.Label(add_row, text="(tip: double-click a product to add it fast)", bg=CARD_BG,
                 fg=TEXT_MUTED, font=FONT_SM).pack(side="left", padx=6)

        right = tk.Frame(wrap, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        right.grid(row=0, column=1, sticky="nsew", padx=(10, 0))

        action_row = tk.Frame(right, bg=CARD_BG)
        action_row.pack(side="bottom", fill="x", padx=16, pady=16)
        action_row.grid_columnconfigure(0, weight=1)
        action_row.grid_columnconfigure(1, weight=1)

        make_button(action_row, "Save Bill", self.save_bill_action, bg=ACCENT, hover=ACCENT_HOVER,
                    font=("Segoe UI", 10, "bold"), icon="💾", padx=8, pady=8).grid(row=0, column=0, sticky="ew", padx=(0, 4))

        make_button(action_row, "Print Bill", self.print_bill_action, bg="#252d3d", hover="#323b4d",
                    fg=TEXT_MAIN, font=("Segoe UI", 10, "bold"), icon="🖨", padx=8, pady=8).grid(row=0, column=1, sticky="ew", padx=(4, 0))

        totals = tk.Frame(right, bg=CARD_BG)
        totals.pack(side="bottom", fill="x", padx=16, pady=(4, 4))
        self.subtotal_lbl = tk.Label(totals, text="Subtotal: 0.00", bg=CARD_BG, fg=TEXT_MUTED, font=FONT)
        self.subtotal_lbl.pack(anchor="e")
        self.grand_total_lbl = tk.Label(totals, text="TOTAL: 0.00", bg=CARD_BG, font=("Segoe UI", 17, "bold"), fg=ACCENT)
        self.grand_total_lbl.pack(anchor="e")

        form = tk.Frame(right, bg=CARD_BG)
        form.pack(side="bottom", fill="x", padx=16, pady=4)
        form.grid_columnconfigure(1, weight=1)

        tk.Label(form, text="Customer Name", bg=CARD_BG, font=FONT_SM, fg=TEXT_MUTED).grid(row=0, column=0, sticky="w")
        self.cust_name_var = tk.StringVar()
        make_entry(form, self.cust_name_var).grid(row=1, column=0, columnspan=2, sticky="ew", pady=(0, 4))

        tk.Label(form, text="Phone", bg=CARD_BG, font=FONT_SM, fg=TEXT_MUTED).grid(row=2, column=0, sticky="w")
        self.cust_phone_var = tk.StringVar()
        make_entry(form, self.cust_phone_var).grid(row=3, column=0, columnspan=2, sticky="ew", pady=(0, 4))

        two_col = tk.Frame(form, bg=CARD_BG)
        two_col.grid(row=4, column=0, columnspan=2, sticky="ew", pady=(0, 4))
        two_col.grid_columnconfigure(0, weight=1)
        two_col.grid_columnconfigure(1, weight=1)

        d_wrap = tk.Frame(two_col, bg=CARD_BG)
        d_wrap.grid(row=0, column=0, sticky="ew", padx=(0, 4))
        tk.Label(d_wrap, text="Discount (flat)", bg=CARD_BG, font=FONT_SM, fg=TEXT_MUTED).pack(anchor="w")
        self.discount_var = tk.StringVar(value="0")
        make_entry(d_wrap, self.discount_var).pack(fill="x")
        self.discount_var.trace_add("write", lambda *a: self.update_totals())

        t_wrap = tk.Frame(two_col, bg=CARD_BG)
        t_wrap.grid(row=0, column=1, sticky="ew", padx=(4, 0))
        tk.Label(t_wrap, text="Tax %", bg=CARD_BG, font=FONT_SM, fg=TEXT_MUTED).pack(anchor="w")
        self.tax_var = tk.StringVar(value=db.get_setting("tax_rate", "5"))
        make_entry(t_wrap, self.tax_var).pack(fill="x")
        self.tax_var.trace_add("write", lambda *a: self.update_totals())

        tk.Label(form, text="Payment Method", bg=CARD_BG, font=FONT_SM, fg=TEXT_MUTED).grid(row=5, column=0, sticky="w")
        self.payment_var = tk.StringVar(value="Cash")
        ttk.Combobox(form, textvariable=self.payment_var, values=["Cash", "Card", "UPI", "Other"],
                     state="readonly", font=FONT).grid(row=6, column=0, columnspan=2, sticky="ew", pady=(0, 2))

        btn_row = tk.Frame(right, bg=CARD_BG)
        btn_row.pack(side="bottom", fill="x", padx=16, pady=4)
        make_button(btn_row, "Remove", self.remove_from_cart, bg="#252d3d", hover="#323b4d",
                    fg=TEXT_MAIN, font=FONT, icon="🗑", padx=10, pady=6).pack(side="left")
        make_button(btn_row, "Clear Cart", self.clear_cart, bg="#252d3d", hover="#323b4d",
                    fg=TEXT_MAIN, font=FONT, icon="✖", padx=10, pady=6).pack(side="left", padx=8)

        tk.Label(right, text="🛒  Current Bill", font=FONT_H2, bg=CARD_BG, fg=TEXT_MAIN).pack(side="top", anchor="w", padx=16, pady=(16, 4))

        cart_wrap = tk.Frame(right, bg=CARD_BG)
        cart_wrap.pack(side="top", fill="both", expand=True, padx=16, pady=(0, 8))
        cart_cols = ("name", "qty", "price", "total")
        self.cart_tree = ttk.Treeview(cart_wrap, columns=cart_cols, show="headings", height=10)
        for c, t, w in zip(cart_cols, ["Item", "Qty", "Price", "Line Total"], [140, 50, 80, 90]):
            self.cart_tree.heading(c, text=t)
            self.cart_tree.column(c, width=w, anchor="center" if c != "name" else "w")
        style_treeview(self.cart_tree)
        self.cart_tree.pack(side="left", fill="both", expand=True)
        add_scrollbar(cart_wrap, self.cart_tree)

        self.refresh_product_list()

    def refresh_product_list(self):
        for row in self.product_tree.get_children():
            self.product_tree.delete(row)
        for i, p in enumerate(db.get_all_products(self.bill_search_var.get().strip() or None)):
            tag = "odd" if i % 2 else "even"
            if p["quantity"] <= p["low_stock_threshold"]:
                tag = "low"
            self.product_tree.insert("", "end", iid=str(p["id"]), tags=(tag,),
                                      values=(p["name"], p["category"] or "-", f"{p['sell_price']:.2f}", p["quantity"]))

    def add_to_cart(self):
        sel = self.product_tree.selection()
        if not sel:
            messagebox.showinfo("Select product", "Please select a product from the list first.")
            return
        pid = int(sel[0])
        product = db.get_product(pid)
        if not product:
            return
        try:
            qty = int(self.qty_var.get())
            if qty <= 0:
                raise ValueError
        except ValueError:
            messagebox.showerror("Invalid quantity", "Enter a valid whole number quantity.")
            return

        already_in_cart = sum(i["quantity"] for i in self.cart if i["product_id"] == pid)
        if qty + already_in_cart > product["quantity"]:
            messagebox.showwarning("Not enough stock",
                                    f"Only {product['quantity']} units of '{product['name']}' in stock.")
            return

        for item in self.cart:
            if item["product_id"] == pid:
                item["quantity"] += qty
                break
        else:
            self.cart.append({
                "product_id": pid,
                "product_name": product["name"],
                "unit_price": product["sell_price"],
                "quantity": qty
            })
        self.render_cart()

    def remove_from_cart(self):
        sel = self.cart_tree.selection()
        if not sel:
            return
        idx = int(sel[0])
        del self.cart[idx]
        self.render_cart()

    def clear_cart(self):
        self.cart = []
        self.render_cart()

    def render_cart(self):
        for row in self.cart_tree.get_children():
            self.cart_tree.delete(row)
        for idx, item in enumerate(self.cart):
            line_total = item["unit_price"] * item["quantity"]
            tag = "odd" if idx % 2 else "even"
            self.cart_tree.insert("", "end", iid=str(idx), tags=(tag,),
                                   values=(item["product_name"], item["quantity"],
                                           f"{item['unit_price']:.2f}", f"{line_total:.2f}"))
        self.update_totals()

    def update_totals(self):
        subtotal = sum(i["unit_price"] * i["quantity"] for i in self.cart)
        try:
            discount = float(self.discount_var.get() or 0)
        except ValueError:
            discount = 0
        try:
            tax_pct = float(self.tax_var.get() or 0)
        except ValueError:
            tax_pct = 0
        tax_amt = (subtotal - discount) * tax_pct / 100 if subtotal > discount else 0
        total = subtotal - discount + tax_amt
        self.subtotal_lbl.config(text=f"Subtotal: {fmt_money(subtotal)}")
        self.grand_total_lbl.config(text=f"TOTAL: {fmt_money(max(total, 0))}")
        self._current_tax_amt = tax_amt
        self._current_discount = discount

    def save_bill_action(self):
        if not self.cart:
            messagebox.showinfo("Empty cart", "Add at least one product to the bill.")
            return
        self.update_totals()
        invoice_no, sale_id, total = db.create_sale(
            self.cart, self._current_discount, self._current_tax_amt,
            customer_name=self.cust_name_var.get().strip() or None,
            customer_phone=self.cust_phone_var.get().strip() or None,
            payment_method=self.payment_var.get()
        )
        self.last_completed_sale_id = sale_id
        messagebox.showinfo("Bill Saved", f"Invoice {invoice_no} saved successfully and inventory updated.")

        self.cart = []
        self.cust_name_var.set("")
        self.cust_phone_var.set("")
        self.discount_var.set("0")
        self.render_cart()
        self.refresh_product_list()
        self.refresh_dashboard()

    def print_bill_action(self):
        if not self.cart and not self.last_completed_sale_id:
            messagebox.showinfo("No Bill", "Please complete a sale or add items to preview print.")
            return
        
        if self.cart:
            self.update_totals()
            win = tk.Toplevel(self)
            win.title("Print Bill Preview")
            win.geometry("420x580")
            win.configure(bg=CARD_BG)

            header = tk.Frame(win, bg=ACCENT, height=56)
            header.pack(fill="x")
            header.pack_propagate(False)
            tk.Label(header, text="🖨  Bill Preview", bg=ACCENT, fg="white", font=("Segoe UI", 13, "bold")).pack(pady=14)

            txt = tk.Text(win, font=("Consolas", 10), bg=CARD_BG, fg=TEXT_MAIN, relief="flat", bd=0)
            txt.pack(fill="both", expand=True, padx=14, pady=10)

            shop_name = db.get_setting("shop_name", "Shri Shakra Sports")
            subtotal = sum(i["unit_price"] * i["quantity"] for i in self.cart)

            lines = [
                shop_name.center(40),
                "-" * 40,
                f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M')}",
                f"Customer: {self.cust_name_var.get().strip() or 'Walk-in'}",
                "-" * 40,
                f"{'Item':<18}{'Qty':>4}{'Price':>9}{'Total':>9}",
                "-" * 40
            ]
            for it in self.cart:
                lt = it["unit_price"] * it["quantity"]
                lines.append(f"{it['product_name'][:18]:<18}{it['quantity']:>4}{it['unit_price']:>9.2f}{lt:>9.2f}")
            lines.extend([
                "-" * 40,
                f"{'Subtotal:':<31}{subtotal:>9.2f}",
                f"{'Discount:':<31}{self._current_discount:>9.2f}",
                f"{'Tax:':<31}{self._current_tax_amt:>9.2f}",
                f"{'TOTAL:':<31}{max(subtotal - self._current_discount + self._current_tax_amt, 0):>9.2f}",
                "-" * 40,
                "Thank you for shopping with us!".center(40)
            ])
            txt.insert("1.0", "\n".join(lines))
            txt.config(state="disabled")
            make_button(win, "Close", win.destroy, bg=ACCENT, hover=ACCENT_HOVER).pack(fill="x", padx=14, pady=(0, 14))
        else:
            self.show_receipt(self.last_completed_sale_id)

    def show_receipt(self, sale_id):
        sale, items = db.get_sale_with_items(sale_id)
        win = tk.Toplevel(self)
        win.title(f"Receipt - {sale['invoice_no']}")
        win.geometry("420x580")
        win.configure(bg=CARD_BG)

        header = tk.Frame(win, bg=GREEN, height=56)
        header.pack(fill="x")
        header.pack_propagate(False)
        tk.Label(header, text="✓  Receipt Print", bg=GREEN, fg="white", font=("Segoe UI", 13, "bold")).pack(pady=14)

        txt = tk.Text(win, font=("Consolas", 10), bg=CARD_BG, fg=TEXT_MAIN, relief="flat", bd=0)
        txt.pack(fill="both", expand=True, padx=14, pady=10)

        shop_name = db.get_setting("shop_name", "Shri Shakra Sports")
        shop_addr = db.get_setting("shop_address", "")
        shop_phone = db.get_setting("shop_phone", "")

        lines = [
            shop_name.center(40),
            shop_addr.center(40) if shop_addr else "",
            f"Ph: {shop_phone}".center(40) if shop_phone else "",
            "-" * 40,
            f"Invoice: {sale['invoice_no']}",
            f"Date: {sale['sale_date']}",
            "-" * 40,
            f"{'Item':<18}{'Qty':>4}{'Price':>9}{'Total':>9}",
            "-" * 40
        ]
        for it in items:
            lines.append(f"{it['product_name'][:18]:<18}{it['quantity']:>4}{it['unit_price']:>9.2f}{it['line_total']:>9.2f}")
        lines.extend([
            "-" * 40,
            f"{'Subtotal:':<31}{sale['subtotal']:>9.2f}",
            f"{'Discount:':<31}{sale['discount']:>9.2f}",
            f"{'Tax:':<31}{sale['tax']:>9.2f}",
            f"{'TOTAL:':<31}{sale['total']:>9.2f}",
            f"Payment: {sale['payment_method']}",
            "-" * 40,
            "Thank you for shopping with us!".center(40)
        ])
        txt.insert("1.0", "\n".join([l for l in lines if l]))
        txt.config(state="disabled")

        make_button(win, "Close", win.destroy, bg=ACCENT, hover=ACCENT_HOVER).pack(fill="x", padx=14, pady=(0, 14))

    # ================= HISTORY (File Explorer Style: Month -> Date -> Bills) =================
    def build_history(self):
        f = self.tab_history
        wrap = tk.Frame(f, bg=BG_PAGE)
        wrap.pack(fill="both", expand=True, padx=22, pady=18)

        SectionHeader(wrap, "Billing History", "View all past bills organized by month and date").pack(fill="x", pady=(0, 14))

        card = tk.Frame(wrap, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        card.pack(fill="both", expand=True)

        tree_wrap = tk.Frame(card, bg=CARD_BG)
        tree_wrap.pack(fill="both", expand=True, padx=16, pady=16)

        cols = ("customer", "total", "payment", "date")
        self.history_tree = ttk.Treeview(tree_wrap, columns=cols, height=18)
        self.history_tree.heading("#0", text="Archive / Invoice #", anchor="w")
        for c, t, w in zip(cols, ["Customer", "Total Amount", "Payment", "Exact Timestamp"], [180, 120, 100, 150]):
            self.history_tree.heading(c, text=t)
            self.history_tree.column(c, width=w, anchor="center" if c != "customer" else "w")
        
        style_treeview(self.history_tree)
        self.history_tree.pack(side="left", fill="both", expand=True)
        add_scrollbar(tree_wrap, self.history_tree)
        
        self.history_tree.bind("<Double-1>", self.view_history_receipt)

    def refresh_history(self):
        for item in self.history_tree.get_children():
            self.history_tree.delete(item)

        conn = db.get_connection()
        rows = conn.execute("""
            SELECT s.*, c.name as customer_name 
            FROM sales s 
            LEFT JOIN customers c ON s.customer_id = c.id 
            ORDER BY s.sale_date DESC
        """).fetchall()
        conn.close()

        months_dict = {}
        for r in rows:
            sale_date_str = r["sale_date"]
            try:
                dt = datetime.strptime(sale_date_str[:19], "%Y-%m-%d %H:%M:%S")
            except Exception:
                try:
                    dt = datetime.strptime(sale_date_str[:10], "%Y-%m-%d")
                except Exception:
                    dt = datetime.now()

            month_key = dt.strftime("%B %Y")
            date_key = dt.strftime("%Y-%m-%d")

            if month_key not in months_dict:
                months_dict[month_key] = {}
            if date_key not in months_dict[month_key]:
                months_dict[month_key][date_key] = []
            months_dict[month_key][date_key].append(r)

        for month_name, dates in months_dict.items():
            month_id = self.history_tree.insert("", "end", text=f"📁 {month_name}", open=True)
            for date_str, sales in dates.items():
                date_id = self.history_tree.insert(month_id, "end", text=f"📂 {date_str}", open=True)
                for s in sales:
                    cust_name = s["customer_name"] or "Walk-in"
                    self.history_tree.insert(
                        date_id, "end", 
                        text=f"📄 {s['invoice_no']}", 
                        values=(cust_name, fmt_money(s["total"]), s["payment_method"], s["sale_date"]),
                        tags=("even",)
                    )

    def view_history_receipt(self, event):
        selected = self.history_tree.selection()
        if not selected:
            return
        item_id = selected[0]
        item_text = self.history_tree.item(item_id, "text")
        if "INV-" in item_text:
            inv_no = item_text.replace("📄 ", "").strip()
            conn = db.get_connection()
            row = conn.execute("SELECT id FROM sales WHERE invoice_no=?", (inv_no,)).fetchone()
            conn.close()
            if row:
                self.show_receipt(row["id"])

    # ================= INVENTORY =================
    def build_inventory(self):
        f = self.tab_inventory
        wrap = tk.Frame(f, bg=BG_PAGE)
        wrap.pack(fill="both", expand=True, padx=22, pady=18)

        SectionHeader(wrap, "Inventory", "Track stock levels and reorder points",
                       button_text="Add Product", button_command=self.open_product_form, button_icon="➕")\
            .pack(fill="x", pady=(0, 14))

        card = tk.Frame(wrap, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        card.pack(fill="both", expand=True)

        search_row = tk.Frame(card, bg=CARD_BG)
        search_row.pack(fill="x", padx=16, pady=(16, 8))
        tk.Label(search_row, text="🔍", bg=CARD_BG, font=FONT).pack(side="left")
        self.inv_search_var = tk.StringVar()
        e = make_entry(search_row, self.inv_search_var, width=34)
        e.pack(side="left", padx=8)
        e.bind("<KeyRelease>", lambda ev: self.refresh_inventory())
        
        self.cat_bar = tk.Frame(search_row, bg=CARD_BG)
        self.cat_bar.pack(side="left", padx=10)

        tk.Label(search_row, text="  🔴 highlighted rows = low stock", bg=CARD_BG,
                 fg=TEXT_MUTED, font=FONT_SM).pack(side="right", padx=10)

        tree_wrap = tk.Frame(card, bg=CARD_BG)
        tree_wrap.pack(fill="both", expand=True, padx=16)
        cols = ("sku", "name", "category", "cost", "price", "qty", "reorder")
        self.inv_tree = ttk.Treeview(tree_wrap, columns=cols, show="headings", height=15)
        headers = ["SKU", "Name", "Category", "Cost", "Sell Price", "Qty", "Reorder At"]
        widths = [90, 200, 130, 80, 90, 70, 90]
        for c, t, w in zip(cols, headers, widths):
            self.inv_tree.heading(c, text=t)
            self.inv_tree.column(c, width=w, anchor="center" if c != "name" else "w")
        style_treeview(self.inv_tree)
        self.inv_tree.pack(side="left", fill="both", expand=True)
        add_scrollbar(tree_wrap, self.inv_tree)

        btn_row = tk.Frame(card, bg=CARD_BG)
        btn_row.pack(fill="x", padx=16, pady=14)
        make_button(btn_row, "Edit Selected", self.edit_selected_product, bg="#252d3d", hover="#323b4d",
                    fg=TEXT_MAIN, font=FONT, icon="✏").pack(side="left")
        make_button(btn_row, "Delete Selected", self.delete_selected_product, bg="#252d3d", hover=RED_LIGHT,
                    fg=RED, font=FONT, icon="🗑").pack(side="left", padx=8)
        make_button(btn_row, "Quick Restock (+10)", self.quick_restock, bg="#252d3d", hover="#323b4d",
                    fg=TEXT_MAIN, font=FONT, icon="📦").pack(side="left")

    def refresh_inventory_categories(self):
        for widget in self.cat_bar.winfo_children():
            widget.destroy()
        self.inv_cat_buttons = {}
        cats = db.get_distinct_categories()
        all_opts = ["All"] + cats
        if self.active_inv_category not in all_opts:
            self.active_inv_category = "All"
        for c in all_opts:
            btn = tk.Button(self.cat_bar, text=c, font=FONT_SM, relief="flat", bd=0, padx=10, pady=4, cursor="hand2")
            btn.config(command=lambda cat=c: self._set_inv_category(cat))
            btn.pack(side="left", padx=(0, 6))
            self.inv_cat_buttons[c] = btn
        self._update_cat_buttons_ui()

    def _set_inv_category(self, cat):
        self.active_inv_category = cat
        self._update_cat_buttons_ui()
        self.refresh_inventory()

    def _update_cat_buttons_ui(self):
        for c, btn in self.inv_cat_buttons.items():
            if c == self.active_inv_category:
                btn.config(bg=ACCENT, fg="#ffffff")
            else:
                btn.config(bg="#252d3d", fg=TEXT_MUTED)

    def refresh_inventory(self):
        for row in self.inv_tree.get_children():
            self.inv_tree.delete(row)
            
        search_term = self.inv_search_var.get().strip() or None
        all_prods = db.get_all_products(search_term)
        if self.active_inv_category and self.active_inv_category != "All":
            all_prods = [p for p in all_prods if p["category"] == self.active_inv_category]

        for i, p in enumerate(all_prods):
            tag = "low" if p["quantity"] <= p["low_stock_threshold"] else ("odd" if i % 2 else "even")
            self.inv_tree.insert("", "end", iid=str(p["id"]), tags=(tag,),
                                  values=(p["sku"] or "-", p["name"], p["category"] or "-",
                                          f"{p['cost_price']:.2f}", f"{p['sell_price']:.2f}",
                                          p["quantity"], p["low_stock_threshold"]))

    def open_product_form(self, product=None):
        win = tk.Toplevel(self)
        win.title("Edit Product" if product else "Add Product")
        win.configure(bg=CARD_BG)
        win.geometry("380x580")
        win.grab_set()

        header = tk.Frame(win, bg=ACCENT, height=50)
        header.pack(fill="x")
        header.pack_propagate(False)
        tk.Label(header, text=("✏  Edit Product" if product else "➕  Add Product"), bg=ACCENT, fg="white",
                 font=FONT_H2).pack(pady=12)

        body = tk.Frame(win, bg=CARD_BG)
        body.pack(fill="both", expand=True, padx=20, pady=14)

        fields = [
            ("SKU", "sku"), ("Name*", "name"), ("Category", "category"),
            ("Cost Price", "cost_price"), ("Sell Price*", "sell_price"),
            ("Quantity", "quantity"), ("Reorder Threshold", "low_stock_threshold")
        ]
        vars_ = {}
        for i, (label, key) in enumerate(fields):
            tk.Label(body, text=label, bg=CARD_BG, font=FONT_SM, fg=TEXT_MUTED).pack(anchor="w", pady=(8 if i == 0 else 6, 0))
            var = tk.StringVar()
            if product:
                default_map = {
                    "sku": product["sku"], "name": product["name"], "category": product["category"],
                    "cost_price": product["cost_price"], "sell_price": product["sell_price"],
                    "quantity": product["quantity"], "low_stock_threshold": product["low_stock_threshold"]
                }
                var.set(default_map.get(key) if default_map.get(key) is not None else "")
            elif key in ("quantity", "cost_price"):
                var.set("0")
            elif key == "low_stock_threshold":
                var.set("5")
            make_entry(body, var).pack(fill="x")
            vars_[key] = var

        def save():
            name = vars_["name"].get().strip()
            if not name:
                messagebox.showerror("Missing name", "Product name is required.")
                return
            try:
                sell_price = float(vars_["sell_price"].get())
                cost_price = float(vars_["cost_price"].get() or 0)
                quantity = int(vars_["quantity"].get() or 0)
                threshold = int(vars_["low_stock_threshold"].get() or 5)
            except ValueError:
                messagebox.showerror("Invalid input", "Price/Quantity/Threshold must be numbers.")
                return

            sku = vars_["sku"].get().strip() or None
            category = vars_["category"].get().strip() or None

            if sku:
                existing = [p for p in db.get_all_products() if p["sku"] == sku and (not product or p["id"] != product["id"])]
                if existing:
                    messagebox.showerror("Duplicate SKU", f"SKU '{sku}' is already used.")
                    return

            try:
                if product:
                    db.update_product(product["id"], sku, name, category, cost_price, sell_price, quantity, threshold)
                else:
                    db.add_product(sku, name, category, cost_price, sell_price, quantity, threshold)
            except Exception as ex:
                messagebox.showerror("Error", f"Could not save product.\n\n{ex}")
                return

            win.destroy()
            self.refresh_inventory_categories()
            self.refresh_inventory()
            self.refresh_product_list()
            self.refresh_dashboard()

        make_button(win, "Save Product", save, bg=GREEN, hover="#047857",
                    font=("Segoe UI", 11, "bold"), icon="💾").pack(fill="x", padx=20, pady=16)

    def edit_selected_product(self):
        sel = self.inv_tree.selection()
        if not sel: return
        self.open_product_form(db.get_product(int(sel[0])))

    def delete_selected_product(self):
        sel = self.inv_tree.selection()
        if not sel: return
        if messagebox.askyesno("Confirm Delete", "Delete this product permanently?"):
            db.delete_product(int(sel[0]))
            self.refresh_inventory_categories()
            self.refresh_inventory()
            self.refresh_product_list()

    def quick_restock(self):
        sel = self.inv_tree.selection()
        if not sel: return
        db.adjust_stock(int(sel[0]), 10)
        self.refresh_inventory()
        self.refresh_product_list()

    # ================= CUSTOMERS =================
    def build_customers(self):
        f = self.tab_customers
        wrap = tk.Frame(f, bg=BG_PAGE)
        wrap.pack(fill="both", expand=True, padx=22, pady=18)

        SectionHeader(wrap, "Customers", "Everyone who's bought from you, and how much they've spent")\
            .pack(fill="x", pady=(0, 14))

        card = tk.Frame(f, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        card.pack(fill="both", expand=True)

        search_row = tk.Frame(card, bg=CARD_BG)
        search_row.pack(fill="x", padx=16, pady=(16, 8))
        tk.Label(search_row, text="🔍", bg=CARD_BG, font=FONT).pack(side="left")
        self.cust_search_var = tk.StringVar()
        e = make_entry(search_row, self.cust_search_var, width=34)
        e.pack(side="left", padx=8)
        e.bind("<KeyRelease>", lambda ev: self.refresh_customers())

        tree_wrap = tk.Frame(card, bg=CARD_BG)
        tree_wrap.pack(fill="both", expand=True, padx=16, pady=(0, 16))
        cols = ("name", "phone", "total_spent")
        self.cust_tree = ttk.Treeview(tree_wrap, columns=cols, show="headings", height=18)
        for c, t, w in zip(cols, ["Name", "Phone", "Total Spent"], [220, 150, 130]):
            self.cust_tree.heading(c, text=t)
            self.cust_tree.column(c, width=w, anchor="center" if c != "name" else "w")
        style_treeview(self.cust_tree)
        self.cust_tree.pack(side="left", fill="both", expand=True)
        add_scrollbar(tree_wrap, self.cust_tree)

        self.refresh_customers()

    def refresh_customers(self):
        for row in self.cust_tree.get_children():
            self.cust_tree.delete(row)
        for i, c in enumerate(db.get_all_customers(self.cust_search_var.get().strip() or None)):
            tag = "odd" if i % 2 else "even"
            self.cust_tree.insert("", "end", values=(c["name"], c["phone"] or "-", fmt_money(c["total_spent"])), tags=(tag,))

    # ================= REPORTS =================
    def build_reports(self):
        f = self.tab_reports
        wrap = tk.Frame(f, bg=BG_PAGE)
        wrap.pack(fill="both", expand=True, padx=22, pady=18)

        SectionHeader(wrap, "Revenue Reports", "Trends, top sellers, and an all-time profit estimate")\
            .pack(fill="x", pady=(0, 14))

        container = tk.Frame(wrap, bg=BG_PAGE)
        container.pack(fill="both", expand=True)
        container.grid_columnconfigure(0, weight=3)
        container.grid_columnconfigure(1, weight=2)
        container.grid_rowconfigure(0, weight=1)

        daily_box = tk.Frame(container, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        daily_box.grid(row=0, column=0, sticky="nsew", padx=(0, 10))
        tk.Label(daily_box, text="📅  Revenue — Last 14 Days", font=FONT_H2, bg=CARD_BG, fg=TEXT_MAIN).pack(anchor="w", padx=14, pady=(14, 4))
        self.daily_canvas = tk.Canvas(daily_box, bg=CARD_BG, height=350, highlightthickness=0)
        self.daily_canvas.pack(fill="both", expand=True, padx=14, pady=(0, 14))
        self.daily_canvas.bind("<Configure>", lambda e: self.refresh_reports())

        right_stack = tk.Frame(container, bg=BG_PAGE)
        right_stack.grid(row=0, column=1, sticky="nsew", padx=(10, 0))
        right_stack.grid_rowconfigure(0, weight=1)
        right_stack.grid_rowconfigure(1, weight=1)
        right_stack.grid_columnconfigure(0, weight=1)

        monthly_box = tk.Frame(right_stack, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        monthly_box.grid(row=0, column=0, sticky="nsew", pady=(0, 8))
        tk.Label(monthly_box, text="📈  Revenue — Last 12 Months", font=FONT_H2, bg=CARD_BG, fg=TEXT_MAIN).pack(anchor="w", padx=14, pady=(12, 4))
        self.monthly_canvas = tk.Canvas(monthly_box, bg=CARD_BG, height=120, highlightthickness=0)
        self.monthly_canvas.pack(fill="both", expand=True, padx=14, pady=(0, 10))
        self.monthly_canvas.bind("<Configure>", lambda e: self.refresh_reports())

        bottom_box = tk.Frame(right_stack, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        bottom_box.grid(row=1, column=0, sticky="nsew", pady=(8, 0))
        tk.Label(bottom_box, text="🏅  Top Selling Products", font=FONT_H2, bg=CARD_BG, fg=TEXT_MAIN).pack(anchor="w", padx=14, pady=(12, 4))
        top_tree_wrap = tk.Frame(bottom_box, bg=CARD_BG)
        top_tree_wrap.pack(fill="both", expand=True, padx=14, pady=(0, 14))
        cols = ("name", "qty", "revenue")
        self.top_tree = ttk.Treeview(top_tree_wrap, columns=cols, show="headings", height=5)
        for c, t, w in zip(cols, ["Product", "Units Sold", "Revenue"], [150, 80, 90]):
            self.top_tree.heading(c, text=t)
            self.top_tree.column(c, width=w, anchor="center" if c != "name" else "w")
        style_treeview(self.top_tree)
        self.top_tree.pack(side="left", fill="both", expand=True)
        add_scrollbar(top_tree_wrap, self.top_tree)

        summary_card = tk.Frame(wrap, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        summary_card.pack(fill="x", pady=(14, 0))
        self.profit_lbl = tk.Label(summary_card, text="", bg=CARD_BG, font=FONT_BOLD, fg=TEXT_MAIN)
        self.profit_lbl.pack(anchor="w", padx=16, pady=12)

        self.refresh_reports()

    def refresh_reports(self):
        self.daily_canvas.delete("all")
        rows = db.revenue_by_day(14)
        self._draw_bar_chart(self.daily_canvas, [(r["day"][5:], r["total"]) for r in rows])

        self.monthly_canvas.delete("all")
        mrows = db.revenue_by_month(12)
        self._draw_bar_chart(self.monthly_canvas, [(r["month"][2:], r["total"]) for r in mrows], compact=True)

        for row in self.top_tree.get_children():
            self.top_tree.delete(row)
        for i, p in enumerate(db.top_selling_products(10)):
            tag = "odd" if i % 2 else "even"
            self.top_tree.insert("", "end", values=(p["product_name"], p["qty_sold"], fmt_money(p["revenue"])), tags=(tag,))

        revenue, cost, profit = db.profit_summary()
        self.profit_lbl.config(
            text=f"📊  All-time Revenue: {fmt_money(revenue)}      🧮  Est. Cost: {fmt_money(cost)}      ✅  Est. Profit: {fmt_money(profit)}"
        )

    def _draw_bar_chart(self, canvas, data, compact=False):
        canvas.update_idletasks()
        w = max(canvas.winfo_width(), 300)
        h = max(canvas.winfo_height(), 120)
        if not data:
            canvas.create_text(w // 2, h // 2, text="No sales data yet", fill=TEXT_MUTED, font=FONT)
            return
        max_val = max((v for _, v in data), default=0) or 1
        n = len(data)
        margin = 30
        bar_area_w = w - 2 * margin
        bar_w = max(bar_area_w / n * 0.6, 4)
        gap = bar_area_w / n
        base_y = h - 30

        for i, (label, val) in enumerate(data):
            x0 = margin + i * gap + (gap - bar_w) / 2
            bar_h = (val / max_val) * (h - 60)
            y0 = base_y - bar_h
            color = ACCENT if val > 0 else "#252d3d"
            canvas.create_rectangle(x0, y0, x0 + bar_w, base_y, fill=color, outline="")
            if not compact or i % max(1, n // 8) == 0:
                canvas.create_text(x0 + bar_w / 2, base_y + 12, text=str(label), font=("Segoe UI", 7), fill=TEXT_MUTED)
            if val > 0:
                canvas.create_text(x0 + bar_w / 2, y0 - 8, text=f"{val:,.0f}", font=("Segoe UI", 7), fill=TEXT_MAIN)

    # ================= SETTINGS =================
    def build_settings(self):
        f = self.tab_settings
        wrap = tk.Frame(f, bg=BG_PAGE)
        wrap.pack(fill="both", expand=True, padx=22, pady=18)

        SectionHeader(wrap, "Shop Settings", "Shown on your receipts and system configuration").pack(fill="x", pady=(0, 14))

        card = tk.Frame(wrap, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        card.pack(fill="x")

        form = tk.Frame(card, bg=CARD_BG)
        form.pack(anchor="w", padx=24, pady=22)

        self.settings_vars = {}
        fields = [
            ("Shop Name", "shop_name"), ("Shop Address", "shop_address"),
            ("Shop Phone", "shop_phone"), ("Default Tax Rate (%)", "tax_rate"),
            ("Currency Symbol", "currency_symbol")
        ]
        for i, (label, key) in enumerate(fields):
            tk.Label(form, text=label, bg=CARD_BG, font=FONT_SM, fg=TEXT_MUTED).grid(row=i, column=0, sticky="w", pady=(10 if i == 0 else 8, 0))
            var = tk.StringVar(value=db.get_setting(key, ""))
            make_entry(form, var, width=38).grid(row=i, column=1, sticky="w", padx=16, pady=(10 if i == 0 else 8, 0))
            self.settings_vars[key] = var

        btn_row = tk.Frame(card, bg=CARD_BG)
        btn_row.pack(anchor="w", padx=24, pady=(0, 22))
        
        make_button(btn_row, "Save Settings", self.save_settings, bg=ACCENT, hover=ACCENT_HOVER, icon="💾").pack(side="left")
        make_button(btn_row, "Reset System & Clear Data", self.reset_system_action, bg="#8b0000", hover="#ff0000", icon="⚠").pack(side="left", padx=12)

        info_card = tk.Frame(wrap, bg=CARD_BG, highlightbackground=CARD_BORDER, highlightthickness=1)
        info_card.pack(fill="x", pady=(14, 0))
        tk.Label(info_card, text=f"🗄  Database file location:\n{db.DB_PATH}", bg=CARD_BG, font=FONT_SM,
                 fg=TEXT_MUTED, justify="left").pack(anchor="w", padx=24, pady=16)

    def save_settings(self):
        for key, var in self.settings_vars.items():
            db.set_setting(key, var.get())
        self.refresh_header()
        messagebox.showinfo("Saved", "Settings updated successfully.")

    def reset_system_action(self):
        confirm = messagebox.askyesno(
            "CRITICAL WARNING", 
            "This will permanently delete all sales history, customer records, and inventory data, and reseed default dummy items.\n\nAre you sure you want to reset?",
            icon="warning"
        )
        if confirm:
            try:
                conn = db.get_connection()
                c = conn.cursor()
                c.execute("DROP TABLE IF EXISTS sale_items")
                c.execute("DROP TABLE IF EXISTS sales")
                c.execute("DROP TABLE IF EXISTS customers")
                c.execute("DROP TABLE IF EXISTS products")
                c.execute("DROP TABLE IF EXISTS settings")
                conn.commit()
                conn.close()
                
                db.init_db()
                seed_dummy_inventory()
                
                messagebox.showinfo("System Reset", "System successfully wiped and restored to fresh state.")
                self.show_page("dashboard")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to reset system:\n{e}")


def main():
    app = App()
    app.mainloop()


if __name__ == "__main__":
    main()