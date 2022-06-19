## База

Асинхронные (данные доступны в том же такте):
* Instructuion memory
* Register file (чтение)

### Program Counter (PC)
содержит адрес текущей инструкции

### Register file (IM)
    чтение
A1->RD1
A2->RD2

    запись
A3 - номер регистра, куда сохранить данные
WD3 - что записать
WE3 - разрешение записи

### Instruction Memory (IM) память инструкций
A - адрес текущей инструкции
RD - выход данных

### Data Memory - ее нет

###  Как работает PC
PC >> 2 -> IM 
<PC содержит адрес первого байта инструкции в памяти, а IM хранит 32-битные слова, каждое из которых состоит из 4 байт.> 
Имеет условную адресацию. Чтобы выполнить корректное чтение, нужно разделить адрес на 4. 

### Как формируются команды
Формат 32-битной машинной команды (признаки — младшие биты всегда «11» и 2-4 биты ≠̸ «111»)
Однако, в декодере в schoolRISCV это нигде не проверяется