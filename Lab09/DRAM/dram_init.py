import random

def get_random_date(month):
    days_in_month = {
        1: 31, 2: 28, 3: 31, 4: 30, 5: 31, 6: 30,
        7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31
    }
    max_days = days_in_month[month]
    return random.randint(1, max_days)

def generate_memory_dump():
    base_address = 0x10000
    
    with open('dram.dat','w') as f:
        for i in range(256):
            addr1 = base_address + (i * 8)
            addr2 = addr1 + 4
            
            month = random.randint(1, 12)
            date = get_random_date(month)
            
            data1 = [random.randint(0, 255) for _ in range(3)]
            data2 = [random.randint(0, 255) for _ in range(3)]
            
            line1 = f"@{addr1:05X}"
            line2 = f"@{addr2:05X}"
            
            hex_data1 = f"{date:02X} {data1[0]:02X} {data1[1]:02X} {data1[2]:02X}"
            hex_data2 = f"{month:02X} {data2[0]:02X} {data2[1]:02X} {data2[2]:02X}"
            
            f.write(f"{line1}\n{hex_data1}\n")
            f.write(f"{line2}\n{hex_data2}\n")

if __name__ == "__main__":
    random.seed()
    generate_memory_dump()