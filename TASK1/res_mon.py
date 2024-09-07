import psutil
import curses

def get_cpu_usage():
    # Получаем использование CPU в процентах
    return psutil.cpu_percent(interval=1)

def get_memory_usage():
    # Получаем использование памяти в процентах и абсолютных значениях
    memory = psutil.virtual_memory()
    memory_usage_percent = memory.percent
    memory_used = memory.used / (1024 ** 2)  # Преобразуем байты в мегабайты
    memory_total = memory.total / (1024 ** 2)  # Преобразуем байты в мегабайты
    return memory_usage_percent, memory_used, memory_total

def monitor_system(stdscr, interval=5):
    curses.curs_set(0)  # Отключаем мигающий курсор
    stdscr.nodelay(1)  # Делаем так, чтобы getch() не блокировал выполнение (чтобы не тыкать каждый раз после изменения значений)
    stdscr.timeout(interval * 1000)  # Таймаут обновления экрана
    
    try:
        while True:
            cpu_usage = get_cpu_usage()
            memory_usage_percent, memory_used, memory_total = get_memory_usage()

            # Очищаем экран и обновляем значения
            stdscr.clear()
            stdscr.addstr(0, 0, "System Monitor", curses.A_BOLD)
            stdscr.addstr(2, 0, f"CPU Usage: {cpu_usage}%")
            stdscr.addstr(3, 0, f"Memory Usage: {memory_usage_percent}% ({memory_used:.2f} MB of {memory_total:.2f} MB)")
            stdscr.addstr(5, 0, "Press 'q' to quit.")
            
            # Обновляем экран
            stdscr.refresh()

            # Проверяем, нажата ли клавиша 'q' для выхода
            key = stdscr.getch()
            if key == ord('q'):
                break
    #Эта конструкция нужна чтобы в терминал не вылетала ошибка, когда работа завершается через CTRL+C вместо q
    except KeyboardInterrupt: 
        pass

if __name__ == "__main__":
    curses.wrapper(monitor_system)
