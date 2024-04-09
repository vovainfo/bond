
#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	Если ДанныеЗаполнения = Неопределено Тогда 
		Возврат;
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("СправочникСсылка.Портфели") Тогда
     	Портфель = ДанныеЗаполнения;
		Для Каждого спрТикер Из ДанныеЗаполнения.Тикеры Цикл
			Если спрТикер.Закрыт Тогда
				Продолжить;				
			КонецЕсли;
			Тикер = Тикеры.Добавить();
			ЗаполнитьЗначенияСвойств(Тикер, спрТикер);
			//@skip-check undefined-variable
			Тикер.Номинал = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(спрТикер.Тикер, "FACEVALUE"); 
			
			//@skip-check undefined-function
			ЗаполнитьЗначенияСвойств(Тикер, ТекущаяЦена_НКД(Тикер.Тикер.SECID, Тикер.Тикер.BOARDID));
			Тикер.СуммаНКД = Тикер.НКД * Тикер.Количество;
			Тикер.СуммаЦена = (Тикер.Цена*Тикер.Номинал/100) * Тикер.Количество;
			Тикер.Сумма = Тикер.СуммаНКД + Тикер.СуммаЦена;
		КонецЦикла;
		Сумма = Тикеры.Итог("Сумма");
		СуммаНКД = Тикеры.Итог("СуммаНКД");
		СуммаЦена = Тикеры.Итог("СуммаЦена");
     КонецЕсли;                               
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
Функция ТекущаяЦена_НКД(SECID, BOARDID)
	URL = СтрШаблон(
			"https://iss.moex.com/iss/engines/stock/markets/bonds/boards/%1/securities.json?securities=%2&iss.meta=off&iss.only=securities,marketdata&iss.json=extended",
			BOARDID,
			SECID
		);

	ДопПараметры = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
	//@skip-check bsl-legacy-check-returning-type-for-environment
	Ответ = КлиентHTTPКлиентСервер.ТелоОтветаКакJSON(ДопПараметры).Получить(URL, , ДопПараметры);
	
	Если Ответ.КодСостояния <> 200 Тогда
		ТекстПредупреждения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						        	НСтр("ru='Ошибка получения данных с биржи. Код ответа <%1>'"),
						        	Ответ.КодСостояния);
		#Если Сервер Тогда
		ОбщегоНазначения.СообщитьПользователю(ТекстПредупреждения);		
		#КонецЕсли
		Возврат Неопределено;		
	КонецЕсли;
	
	Попытка
		Marketdata = Ответ.Тело[1].marketdata[0];
		Securities = Ответ.Тело[1].securities[0];
	Исключение
		Возврат Новый Структура("Цена, НКД, Номинал, ДатаКупона", 0, 0, 0, Дата(1,1,1));
	КонецПопытки;
	
	Попытка
		Цена = Число(Marketdata.last);	
	Исключение
		Цена = Число(Securities.prevlegalcloseprice);	
	КонецПопытки;
	
	НКД = Число(Securities.accruedint);
	Номинал = Securities.facevalue;
	ДатаКупона = ПрочитатьДатуJSON(Securities.NEXTCOUPON, ФорматДатыJSON.ISO); 
	
	//@skip-check structure-consructor-too-many-keys
	Возврат Новый Структура("Цена, НКД, Номинал, ДатаКупона", Цена, НКД, Номинал, ДатаКупона);
КонецФункции
#Иначе
  ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли
#КонецОбласти
