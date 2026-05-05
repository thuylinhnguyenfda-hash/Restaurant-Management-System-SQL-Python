import mysql.connector
from datetime import datetime

# ============================================================
# CONNECT DATABASE
# ============================================================
def connect():
    return mysql.connector.connect(
        host='127.0.0.1',
        user='root',
        password='123456789',  
        database='Restaurant'
    )


# ============================================================
# CUSTOMER MANAGEMENT
# ============================================================
def add_customer():
    name    = input("  Customer Name : ")
    phone   = input("  Phone Number  : ")
    address = input("  Address       : ")
    conn = connect()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO Customers (CustomerName, PhoneNumber, Address)
            VALUES (%s, %s, %s)
        """, (name, phone, address))
        conn.commit()
        new_id = cursor.lastrowid  # Lay ID vua insert
        print(f"  -> Added customer: {name} (CustomerID: {new_id})")
    except mysql.connector.Error as e:
        print(f"  -> Error: {e}")
    finally:
        conn.close()

def update_customer():
    cid     = input("  CustomerID to update      : ")
    phone   = input("  New Phone (Enter to skip) : ")
    address = input("  New Address (Enter to skip): ")
    conn = connect()
    cursor = conn.cursor()
    try:
        if phone:
            cursor.execute("UPDATE Customers SET PhoneNumber=%s WHERE CustomerID=%s", (phone, cid))
        if address:
            cursor.execute("UPDATE Customers SET Address=%s WHERE CustomerID=%s", (address, cid))
        conn.commit()
        print(f"  -> Updated CustomerID: {cid}")
    except mysql.connector.Error as e:
        print(f"  -> Error: {e}")
    finally:
        conn.close()

def view_customers():
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Customers ORDER BY CustomerID LIMIT 20")
    rows = cursor.fetchall()
    print(f"\n  {'ID':<6} {'Name':<25} {'Phone':<15} {'Address'}")
    print("  " + "-" * 90)
    for r in rows:
        print(f"  {r['CustomerID']:<6} {r['CustomerName']:<25} {r['PhoneNumber']:<15} {str(r['Address'])}")
    conn.close()

def search_customer():
    keyword = input("  Search keyword : ")
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT * FROM Customers
        WHERE CustomerName LIKE %s OR PhoneNumber LIKE %s
    """, (f'%{keyword}%', f'%{keyword}%'))
    rows = cursor.fetchall()
    print(f"\n  {'ID':<6} {'Name':<25} {'Phone':<15} {'Address'}")
    print("  " + "-" * 90)
    for r in rows:
        print(f"  {r['CustomerID']:<6} {r['CustomerName']:<25} {r['PhoneNumber']:<15} {str(r['Address'])}")
    conn.close()


# ============================================================
# TABLE MANAGEMENT
# ============================================================
def add_table():
    number = input("  Table Number (e.g. T001) : ")
    status = input("  Status (available/reserved) : ")
    conn = connect()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO `Tables` (TableNumber, Status)
            VALUES (%s, %s)
        """, (number, status))
        conn.commit()
        print(f"  -> Added table: {number}")
    except mysql.connector.Error as e:
        print(f"  -> Error: {e}")
    finally:
        conn.close()

def view_available_tables():
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM vw_AvailableTables")
    rows = cursor.fetchall()
    print(f"\n  {'ID':<6} {'TableNumber':<15} {'Status'}")
    print("  " + "-" * 35)
    for r in rows:
        print(f"  {r['TableID']:<6} {r['TableNumber']:<15} {r['Status']}")
    conn.close()

def update_table_status():
    tid    = input("  TableID : ")
    status = input("  New Status (available/reserved/occupied) : ")
    conn = connect()
    cursor = conn.cursor()
    try:
        cursor.execute("UPDATE `Tables` SET Status=%s WHERE TableID=%s", (status, tid))
        conn.commit()
        print(f"  -> Updated TableID {tid} to '{status}'")
    except mysql.connector.Error as e:
        print(f"  -> Error: {e}")
    finally:
        conn.close()


# ============================================================
# MENU MANAGEMENT
# ============================================================
def add_dish():
    name  = input("  Dish Name : ")
    price = input("  Price     : ")
    conn = connect()
    cursor = conn.cursor()
    try:
        cursor.execute("INSERT INTO MenuItems (DishName, Price) VALUES (%s, %s)", (name, price))
        conn.commit()
        new_id = cursor.lastrowid  # Lay ID vua insert
        print(f"  -> Added dish: {name} (DishID: {new_id})")
    except mysql.connector.Error as e:
        print(f"  -> Error: {e}")
    finally:
        conn.close()

def update_dish():
    did   = input("  DishID            : ")
    name  = input("  New Name  (Enter to skip) : ")
    price = input("  New Price (Enter to skip) : ")
    conn = connect()
    cursor = conn.cursor()
    try:
        if name:
            cursor.execute("UPDATE MenuItems SET DishName=%s WHERE DishID=%s", (name, did))
        if price:
            cursor.execute("UPDATE MenuItems SET Price=%s WHERE DishID=%s", (price, did))
        conn.commit()
        print(f"  -> Updated DishID: {did}")
    except mysql.connector.Error as e:
        print(f"  -> Error: {e}")
    finally:
        conn.close()

def view_menu():
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM MenuItems ORDER BY DishID LIMIT 20")
    rows = cursor.fetchall()
    print(f"\n  {'ID':<6} {'Dish Name':<50} {'Price':>12}")
    print("  " + "-" * 70)
    for r in rows:
        print(f"  {r['DishID']:<6} {r['DishName']:<50} {r['Price']:>12,.0f}")
    conn.close()


# ============================================================
# RESERVATION MANAGEMENT
# ============================================================
def make_reservation():
    cid   = input("  CustomerID  : ")
    tid   = input("  TableID     : ")
    dt    = input("  DateTime (YYYY-MM-DD HH:MM:SS) : ")
    guest = input("  Guest Count : ")
    conn = connect()
    cursor = conn.cursor()
    try:
        args = [int(cid), int(tid), dt, int(guest), '']
        result = cursor.callproc('sp_MakeReservation', args)
        conn.commit()
        print(f"  -> {result[4]}")  # result[4] la OUT parameter p_Message
    except mysql.connector.Error as e:
        print(f"  -> Error: {e}")
    finally:
        conn.close()

def view_today_reservations():
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM vw_TodayReservations")
    rows = cursor.fetchall()
    if not rows:
        print("  -> No reservations today.")
        conn.close()
        return
    print(f"\n  {'ID':<6} {'Customer':<20} {'Phone':<15} {'Table':<8} {'DateTime':<22} {'Guests'}")
    print("  " + "-" * 90)
    for r in rows:
        print(f"  {r['ReservationID']:<6} {r['CustomerName']:<20} {r['PhoneNumber']:<15} "
              f"{r['TableNumber']:<8} {str(r['DateTime']):<22} {r['GuestCount']}")
    conn.close()


# ============================================================
# INVOICE MANAGEMENT
# ============================================================
def order_food():
    """
    Allows adding multiple dishes to a specific InvoiceID.
    Loops until the user enters '0' for DishID.
    Displays DishName upon successful order.
    """
    print("\n  [ ORDER FOOD ]")
    inv_id = input("  InvoiceID : ")
    
    conn = connect()
    cursor = conn.cursor()
    
    print("  --- Enter DishID to order. Enter '0' to finish. ---")
    while True:
        dish_id = input("  DishID (or '0' to finish): ")
        
        # Exit condition
        if dish_id == '0':
            print(f"  -> Order finalized for InvoiceID: {inv_id}")
            break
            
        qty = input("  Quantity : ")
        
        try:
            # SỬA LẠI Ở ĐÂY: Lấy cả Price và DishName từ Database
            cursor.execute("SELECT Price, DishName FROM MenuItems WHERE DishID = %s", (dish_id,))
            result = cursor.fetchone()
            
            if not result:
                print("  -> [!] Error: DishID not found in Menu. Please try again.")
                continue 
                
            unit_price = result[0]
            dish_name = result[1]  # Lấy tên món ăn từ kết quả trả về
            
            # Chèn vào bảng InvoiceDetails
            cursor.execute("""
                INSERT INTO InvoiceDetails (InvoiceID, DishID, Quantity, UnitPrice)
                VALUES (%s, %s, %s, %s)
            """, (inv_id, dish_id, qty, unit_price))
            
            conn.commit()
            # Hien tong tien hien tai sau khi them mon
            cursor.execute("""
                SELECT TotalAmount FROM Invoices WHERE InvoiceID = %s
            """, (inv_id,))
            current = cursor.fetchone()
            if current:
                print(f"  -> Current Total: {current[0]:,.0f} VND")
            
            # SỬA LẠI Ở ĐÂY: In ra tên món ăn (dish_name) để xác nhận
            print(f"  -> [OK] Added {qty}x '{dish_name}' (DishID: {dish_id}) to Invoice {inv_id}.")
            
        except mysql.connector.Error as e:
            print(f"  -> Database Error: {e}")
            
    conn.close()

def generate_invoice():
    print("\n  [ GENERATE INVOICE ]")
    cid = input("  CustomerID : ")
    tid = input("  TableID    : ")
    
    conn = connect()
    cursor = conn.cursor()
    try:
        # --- NEW LOGIC: Prevent generating invoice for future reservations ---
        cursor.execute("""
            SELECT DateTime FROM Reservations 
            WHERE CustomerID = %s AND TableID = %s 
            ORDER BY DateTime DESC LIMIT 1
        """, (cid, tid))
        
        res_record = cursor.fetchone()
        
        if res_record:
            res_date = res_record[0]
            # Check if the reservation is in the future compared to current time
            if res_date > datetime.now():
                print(f"  -> [!] Error: Cannot generate invoice. The reservation is in the future ({res_date}).")
                print("  -> Please wait until the customer arrives to open the table.")
                return # Dừng việc tạo hóa đơn tại đây
        # ---------------------------------------------------------------------

        # Nếu thời gian hợp lệ (khách đã đến), tiến hành tạo hóa đơn
        args = [int(cid), int(tid), 0, '']
        result = cursor.callproc('sp_GenerateInvoice', args)
        conn.commit()
        print(f"  -> InvoiceID generated: {result[2]}")
        print(f"  -> System Message: {result[3]}")
    except mysql.connector.Error as e:
        print(f"  -> Database Error: {e}")
    finally:
        conn.close()

def view_invoices():
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT i.InvoiceID, c.CustomerName, t.TableNumber,
               i.TotalAmount, i.PaymentDate,
               fn_TotalWithTax(i.TotalAmount) AS FinalAmount
        FROM Invoices i
        JOIN Customers c ON i.CustomerID = c.CustomerID
        JOIN `Tables`  t ON i.TableID    = t.TableID
        ORDER BY i.PaymentDate DESC
        LIMIT 20
    """)
    rows = cursor.fetchall()
    print(f"\n  {'ID':<6} {'Customer':<25} {'Table':<8} {'Total':<15} {'Final+Tax':<15} {'Date'}")
    print("  " + "-" * 95)
    for r in rows:
        print(f"  {r['InvoiceID']:<6} {r['CustomerName']:<25} {r['TableNumber']:<8} "
              f"{r['TotalAmount']:<15,.0f} {r['FinalAmount']:<15,.0f} {str(r['PaymentDate'])}")
    conn.close()

def view_specific_invoice():
    """
    Displays the details (receipt) of a specific invoice, including
    customer info, table number, and a list of ordered dishes.
    """
    print("\n  [ VIEW SPECIFIC INVOICE ]")
    inv_id = input("  Enter InvoiceID : ")
    
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    try:
        # 1. Fetch general invoice information (Header)
        cursor.execute("""
            SELECT i.InvoiceID, c.CustomerName, t.TableNumber, i.PaymentDate, i.TotalAmount
            FROM Invoices i
            JOIN Customers c ON i.CustomerID = c.CustomerID
            JOIN `Tables` t ON i.TableID = t.TableID
            WHERE i.InvoiceID = %s
        """, (inv_id,))
        header = cursor.fetchone()
        
        if not header:
            print(f"  -> [!] Error: InvoiceID {inv_id} not found.")
            return
            
        # Print Receipt Header
        print("\n  " + "=" * 55)
        print(f"   RESTAURANT RECEIPT - Invoice #{header['InvoiceID']}")
        print(f"   Customer : {header['CustomerName']}")
        print(f"   Table    : {header['TableNumber']}")
        print(f"   Date     : {header['PaymentDate']}")
        print("  " + "=" * 55)
        
        # 2. Fetch the list of ordered dishes (Details)
        cursor.execute("""
            SELECT m.DishName, d.Quantity, d.UnitPrice, (d.Quantity * d.UnitPrice) as SubTotal
            FROM InvoiceDetails d
            JOIN MenuItems m ON d.DishID = m.DishID
            WHERE d.InvoiceID = %s
        """, (inv_id,))
        details = cursor.fetchall()
        
        print(f"   {'Dish Name':<25} {'Qty':>5} {'Price':>10} {'SubTotal':>10}")
        print("   " + "-" * 53)
        
        if not details:
            print("   (No items ordered yet)")
        else:
            for r in details:
                print(f"   {r['DishName']:<25} {r['Quantity']:>5} {r['UnitPrice']:>10,.0f} {r['SubTotal']:>10,.0f}")
                
        # Print Total Amount
        print("  " + "=" * 55)
        print(f"   TOTAL AMOUNT: {header['TotalAmount']:>38,.0f}")
        print("  " + "=" * 55 + "\n")
        
    except mysql.connector.Error as e:
        print(f"  -> Database Error: {e}")
    finally:
        conn.close()

# ============================================================
# REPORTS
# ============================================================
def report_revenue():
    start = input("  Start date (YYYY-MM-DD) : ")
    end   = input("  End date   (YYYY-MM-DD) : ")
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT RevenueDate, TotalInvoices, TotalRevenue
        FROM vw_DailyRevenue
        WHERE RevenueDate BETWEEN %s AND %s
    """, (start, end))
    rows = cursor.fetchall()
    print(f"\n  {'Date':<15} {'Invoices':>10} {'Revenue':>20}")
    print("  " + "-" * 48)
    total = 0
    for r in rows:
        print(f"  {str(r['RevenueDate']):<15} {r['TotalInvoices']:>10} {r['TotalRevenue']:>20,.0f}")
        total += r['TotalRevenue']
    print("  " + "-" * 48)
    print(f"  {'TOTAL':<15} {'':>10} {total:>20,.0f}")
    conn.close()

def report_top_dishes():
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM vw_TopSellingDishes")
    rows = cursor.fetchall()
    print(f"\n  {'Dish':<40} {'Sold':>8} {'Revenue':>20}")
    print("  " + "-" * 70)
    for r in rows:
        print(f"  {r['DishName']:<40} {r['TotalSold']:>8} {r['TotalRevenue']:>20,.0f}")
    conn.close()

def report_table_usage():
    conn = connect()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT t.TableNumber,
               COUNT(DISTINCT r.ReservationID) AS TotalReservations,
               COUNT(DISTINCT i.InvoiceID)     AS TotalInvoices
        FROM `Tables` t
        LEFT JOIN Reservations r ON t.TableID = r.TableID
        LEFT JOIN Invoices     i ON t.TableID = i.TableID
        GROUP BY t.TableID, t.TableNumber
        ORDER BY TotalReservations DESC
        LIMIT 10
    """)
    rows = cursor.fetchall()
    print(f"\n  {'Table':<12} {'Reservations':>15} {'Invoices':>12}")
    print("  " + "-" * 42)
    for r in rows:
        print(f"  {r['TableNumber']:<12} {r['TotalReservations']:>15} {r['TotalInvoices']:>12}")
    conn.close()


# ============================================================
# MAIN MENU
# ============================================================
def main():
    while True:
        print("\n" + "=" * 45)
        print("     RESTAURANT MANAGEMENT SYSTEM")
        print("=" * 45)
        print("  1. Customer Management")
        print("  2. Table Management")
        print("  3. Menu Management")
        print("  4. Reservation Management")
        print("  5. Invoice Management")
        print("  6. Reports")
        print("  0. Exit")
        print("-" * 45)
        choice = input("  Select: ").strip()

        if choice == '1':
            print("\n  [1] Add customer  [2] Update customer  [3] View all customers  [4] Search customer")
            sub = input("  Sub: ").strip()
            if sub == '1':   add_customer()
            elif sub == '2': update_customer()
            elif sub == '3': view_customers()
            elif sub == '4': search_customer()

        elif choice == '2':
            print("\n  [1] Add Table  [2] View Available  [3] Update Status")
            sub = input("  Sub: ").strip()
            if sub == '1':   add_table()
            elif sub == '2': view_available_tables()
            elif sub == '3': update_table_status()

        elif choice == '3':
            print("\n  [1] Add Dish  [2] Update Dish  [3] View Menu")
            sub = input("  Sub: ").strip()
            if sub == '1':   add_dish()
            elif sub == '2': update_dish()
            elif sub == '3': view_menu()

        elif choice == '4':
            print("\n  [1] Make Reservation  [2] View Today Reservations")
            sub = input("  Sub: ").strip()
            if sub == '1':   make_reservation()
            elif sub == '2': view_today_reservations()

        elif choice == '5':
            print("\n  [1] Generate Invoice  [2] Order Food  [3] View Invoices  [4] View Specific Invoice")
            sub = input("  Sub: ").strip()
            if sub == '1':   generate_invoice()
            elif sub == '2': order_food()
            elif sub == '3': view_invoices()
            elif sub == '4': view_specific_invoice()


        elif choice == '6':
            print("\n  [1] Revenue Report  [2] Top Dishes  [3] Table Usage")
            sub = input("  Sub: ").strip()
            if sub == '1':   report_revenue()
            elif sub == '2': report_top_dishes()
            elif sub == '3': report_table_usage()

        elif choice == '0':
            print("\n  Goodbye!")
            break
        else:
            print("  -> Invalid option, please try again!")

if __name__ == '__main__':
    main()