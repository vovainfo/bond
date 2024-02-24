///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ТекущаяВерсия = СистемнаяИнформация.ВерсияПриложения;
	
	ВсеНерекомендуемыеВерсии = ОбщегоНазначения.НедопустимыеВерсииПлатформы();
	
	ОбщиеПараметры    = ОбщегоНазначения.ОбщиеПараметрыБазовойФункциональности();
	МинимальнаяВерсия = ОбщиеПараметры.МинимальнаяВерсияПлатформы;
	
	Уточнение = "";
	УточнениеПерезапуск = "";
	Если Не ОбщегоНазначения.ИнформационнаяБазаФайловая()
		Или ОбщегоНазначения.ЭтоВебКлиент() Тогда
		Уточнение = НСтр("ru = 'Для этого обратитесь к администратору.'");
	КонецЕсли;
	
	Если Не ОбщегоНазначения.ЭтоLinuxКлиент()
		И Не ОбщегоНазначения.ЭтоВебКлиент()
		И ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда 
		
		КаталогПлатформы = КаталогПлатформыДляЗапуска(ТекущаяВерсия, ВсеНерекомендуемыеВерсии);
		Если ЗначениеЗаполнено(КаталогПлатформы) Тогда
			Элементы.ФормаПерезапустить.Видимость = Истина;
			Элементы.ФормаПерезапустить.КнопкаПоУмолчанию = Истина;
			УточнениеПерезапуск = Символы.ПС + Символы.ПС + НСтр("ru = 'Перезапустите программу на подходящей версии платформы (кнопка <b>Перезапустить</b>).'");
		КонецЕсли;
	КонецЕсли;
	
	Элементы.Предупреждение.Заголовок = СтроковыеФункции.ФорматированнаяСтрока(Элементы.Предупреждение.Заголовок, 
		"<b>" + ТекущаяВерсия + "</b>",
		УточнениеПерезапуск,
		"<b>" + МинимальнаяВерсия + "</b>",
		Уточнение);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИнструкцияПоОбновлениюНажатие(Элемент) 
	ПараметрыОбновления = Новый Структура;
	ПараметрыОбновления.Вставить("ИнструкцияДляФайловой", Истина);
	
	ОткрытьФорму("Обработка.НерекомендуемаяВерсияПлатформы.Форма.ПорядокОбновленияПлатформы", ПараметрыОбновления, ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ИнструкцияПоУдалениюПлатформыНажатие(Элемент)
	ПараметрыОбновления = Новый Структура;
	ПараметрыОбновления.Вставить("УдалениеПрограммы", Истина);
	ПараметрыОбновления.Вставить("ВерсияПлатформы", ТекущаяВерсия);
	
	ОткрытьФорму("Обработка.НерекомендуемаяВерсияПлатформы.Форма.ПорядокОбновленияПлатформы", ПараметрыОбновления, ЭтотОбъект);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Перезапустить(Команда)
	
	КомандаЗапуска = Новый Массив;
	КомандаЗапуска.Добавить(КаталогПлатформы + "1cv8.exe");
	КомандаЗапуска.Добавить("ENTERPRISE");
	КомандаЗапуска.Добавить("/IBConnectionString");
	КомандаЗапуска.Добавить(СтрокаСоединенияИнформационнойБазы());
	КомандаЗапуска.Добавить("AppAutoCheckVersion-");
	
	ПараметрыЗапускаПрограммы = ФайловаяСистемаКлиент.ПараметрыЗапускаПрограммы();
	ПараметрыЗапускаПрограммы.Оповещение = Новый ОписаниеОповещения("ПерезапуститьЗавершение", ЭтотОбъект);
	ПараметрыЗапускаПрограммы.ДождатьсяЗавершения = Ложь;
	
	ФайловаяСистемаКлиент.ЗапуститьПрограмму(КомандаЗапуска, ПараметрыЗапускаПрограммы);
	
КонецПроцедуры 

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция КаталогПлатформыДляЗапуска(ТекущаяВерсия, ВсеНерекомендуемыеВерсии)
	
	КаталогПрограммы = КаталогПрограммы();
	КаталогПрограммыЧастями = СтрРазделить(КаталогПрограммы, ПолучитьРазделительПути(), Ложь); 
	НайденнаяПлатформа = Неопределено;
	Если КаталогПрограммыЧастями.Количество() > 2 Тогда
		КаталогПрограммыЧастями.Удалить(КаталогПрограммыЧастями.ВГраница());
		КаталогПрограммыЧастями.Удалить(КаталогПрограммыЧастями.ВГраница());
		
		КаталогПрограммы = СтрСоединить(КаталогПрограммыЧастями, ПолучитьРазделительПути());
		
		ДоступныеПлатформы = НайтиФайлы(КаталогПрограммы, "*");
		
		ТаблицаВерсийПлатформы = ТаблицаВерсийПлатформы(ДоступныеПлатформы, ВсеНерекомендуемыеВерсии);
		
		НайденнаяПлатформа = НайденнаяПлатформа(ТаблицаВерсийПлатформы, ТекущаяВерсия);
	КонецЕсли;
	
	Если НайденнаяПлатформа <> Неопределено Тогда
		КаталогПлатформы = НайденнаяПлатформа.ПолныйПуть + ПолучитьРазделительПути() + "bin" + ПолучитьРазделительПути();
		Возврат КаталогПлатформы;
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ТаблицаВерсийПлатформы(Платформы, ВсеНерекомендуемыеВерсии)
	
	Таблица = Новый ТаблицаЗначений;
	Таблица.Колонки.Добавить("Сборка");
	Таблица.Колонки.Добавить("Версия");
	Таблица.Колонки.Добавить("ПолныйПуть");
	Таблица.Колонки.Добавить("ВесВерсии");
	
	Разделитель = ПолучитьРазделительПути();
	
	ВсеМинимальные = ОбщегоНазначения.МинимальнаяВерсияПлатформы();
	ВсеМинимальныеЧастями = СтрРазделить(ВсеМинимальные, "; ");
	СоответствиеМинимальныхСборок = Новый Соответствие;
	Для Каждого Минимальная Из ВсеМинимальныеЧастями Цикл
		МинимальнаяВерсия = ОбщегоНазначенияКлиентСервер.ВерсияКонфигурацииБезНомераСборки(Минимальная);
		СоответствиеМинимальныхСборок.Вставить(МинимальнаяВерсия, Минимальная);
	КонецЦикла;
	
	Для Каждого Платформа Из Платформы Цикл 
		Если Не СтрНачинаетсяС(Платформа.Имя, "8.3.") Тогда
			Продолжить;
		КонецЕсли;
		
		Если СтрНайти(ВсеНерекомендуемыеВерсии, Платформа.Имя) Тогда
			Продолжить;
		КонецЕсли;
		
		Если ОбщегоНазначенияКлиентСервер.СравнитьВерсииБезНомераСборки(Платформа.ИмяБезРасширения, "8.3.21") < 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Если СоответствиеМинимальныхСборок[Платформа.ИмяБезРасширения] <> Неопределено
			И ОбщегоНазначенияКлиентСервер.СравнитьВерсии(Платформа.Имя, СоответствиеМинимальныхСборок[Платформа.ИмяБезРасширения]) < 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяИсполняемогоФайла = Платформа.ПолноеИмя + Разделитель + "bin" + Разделитель + "1cv8.exe";
		Файл = Новый Файл(ИмяИсполняемогоФайла);
		Если Не Файл.Существует() Тогда
			Продолжить;
		КонецЕсли;
		
		Строка = Таблица.Добавить();
		Строка.Сборка = Платформа.Имя;
		Строка.Версия = Платформа.ИмяБезРасширения;
		Строка.ПолныйПуть = Платформа.ПолноеИмя;
		Строка.ВесВерсии = ВесВерсии(Платформа.Имя);
	КонецЦикла;
	
	Таблица.Сортировать("ВесВерсии Убыв");
	
	Возврат Таблица;
	
КонецФункции

&НаСервере
Функция ВесВерсии(НомерСборки)
	НомерСборкиЧастями = СтрРазделить(НомерСборки, ".");
	
	Вес = Число(НомерСборкиЧастями[0]) * 10000000
		+ Число(НомерСборкиЧастями[1]) * 1000000
		+ Число(НомерСборкиЧастями[2]) * 10000
		+ Число(НомерСборкиЧастями[3]);
	
	Возврат Вес;
КонецФункции

&НаСервере
Функция НайденнаяПлатформа(ТаблицаВерсийПлатформы, ТекущаяВерсия)
	
	Версия = ОбщегоНазначенияКлиентСервер.ВерсияКонфигурацииБезНомераСборки(ТекущаяВерсия);
	ПодходящаяСборка = ТаблицаВерсийПлатформы.Найти(Версия, "Версия");
	Пока ПодходящаяСборка = Неопределено Цикл
		ВерсияЧастями = СтрРазделить(Версия, ".");
		НомерВерсии = ВерсияЧастями[2];
		ОписаниеТипов = Новый ОписаниеТипов("Число");
		Попытка
			НомерВерсии = ОписаниеТипов.ПривестиЗначение(НомерВерсии);
		Исключение
			Возврат Неопределено;
		КонецПопытки;
		НомерВерсии = НомерВерсии - 1;
		Если НомерВерсии < 21 Тогда // 8.3.21
			Возврат Неопределено;
		КонецЕсли;
		ВерсияЧастями[2] = Строка(НомерВерсии);
		Версия = СтрСоединить(ВерсияЧастями, ".");
		ПодходящаяСборка = ТаблицаВерсийПлатформы.Найти(Версия, "Версия");
	КонецЦикла;
	
	Возврат ПодходящаяСборка;
	
КонецФункции

&НаКлиенте
Процедура ПерезапуститьЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ЗавершитьРаботуСистемы(Ложь, Ложь);
	
КонецПроцедуры

#КонецОбласти
