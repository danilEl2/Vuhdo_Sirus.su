# VuhDo for Sirus

Модификация VuhDo 2.23: отображение поглощений на рейд-фреймах.

## Описание

Данная модицикация аддона VuhDo 2.23 для проекта Sirus.su.  
На Sirus клиент предоставляет `UnitGetTotalAbsorbs(unit)`.  
VuhDo читает значение через `VUHDO_getAbsorbOnUnit()` и рисует оверлей поверх HP/Incoming heal.  

## Для кого  
Модификация будет полезна для ДЦ жрецов для мониторинга текущего значених эффектов поглощения от заклинаний `Слово Силы: Щит` и дополнительное поглощения от таланта `Божественное покровительство`.

## Примеры Sirus ToolTip:  
<img width="245" height="86" alt="image" src="https://github.com/user-attachments/assets/41c514d2-e78a-49c3-b7c6-dbdf8c0128bd" />
<img width="284" height="76" alt="image" src="https://github.com/user-attachments/assets/d192be49-c940-4456-bc85-4a83810674dc" />  
<img width="417" height="78" alt="image" src="https://github.com/user-attachments/assets/acca4fa5-1c40-4492-986e-4fea1af14cb2" />

## Установка
1. Скопировать `VuhDo` и `VuhDoOptions` в `Interface\AddOns\`
2. `/reload`

## Настройки
- Общее -> Входящее -> «Поглощение» (по умолчанию выкл.)  
- Цвета -> Режимы -> «Абсорбы»
<img width="941" height="657" alt="image" src="https://github.com/user-attachments/assets/bce7ec52-b8e8-481d-b107-ed4f04158d59" />  
<img width="942" height="655" alt="image" src="https://github.com/user-attachments/assets/c21f8c66-8f93-4084-a99d-422dc16222e0" />  

## Поглощение в VuhDo фреймах  
<img width="510" height="245" alt="image" src="https://github.com/user-attachments/assets/c0332918-0306-4804-b781-e91e305918dc" />  
<img width="218" height="213" alt="image" src="https://github.com/user-attachments/assets/938cc0ce-c552-4243-9505-96cd6d6215dd" />  
<img width="165" height="125" alt="image" src="https://github.com/user-attachments/assets/e972f3aa-083a-41c8-bd3a-9ff9c9762d45" />  
