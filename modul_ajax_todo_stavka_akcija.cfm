<cfsetting showdebugoutput="no"><cfcontent type="text/xml; charset=utf-8"><?xml version="1.0" encoding="utf-8"?>
<cfprocessingdirective pageEncoding="utf-8"><!--- šđčžćŠĐČĆŽ --->
<cfprocessingdirective suppresswhitespace="yes">

<cfset greska = 0>
<cfset poruka = "">

<cfset id_stavke = "">
<cfif IsDefined("URL.id_stavke")>
	<cfset id_stavke = #URL.id_stavke#>
<cfelseif IsDefined("form.id_stavke")>
	<cfset id_stavke = #form.id_stavke#>
</cfif>


<cfset brisanje = 0>
<cfif IsDefined("URL.brisanje")>
	<cfset brisanje = #Val(URL.brisanje)#>
<cfelseif IsDefined("form.brisanje")>
	<cfset brisanje = #Val(form.brisanje)#>
</cfif>

<cftry>
	<!--- brisanje --->
	<cfif (#brisanje# eq 1)>
		<cfif (#id_stavke# not equal "")>
			<cfquery name="brisanje_stavke" datasource="#SESSION.baza_podataka#">
				UPDATE ttd_lista_sadrzaj_detalji 
				SET 
					obrisano = 1, 
					id_obrisao = #SESSION.id_korisnika# 
				WHERE ttd_lista_sadrzaj_detalji.id = #id_stavke#
			</cfquery>
		<cfelse>
			<cfset greska = 1>
			<cfset poruka = poruka & "Stavka nije definisana.<br />">
		</cfif>


	<!--- unos / izmjena --->
	<cfelse>
		<cfset id_pacijenta = 0>
		<cfif IsDefined("URL.id_pacijenta")>
			<cfset id_pacijenta = #Val(URL.id_pacijenta)#>
		<cfelseif IsDefined("form.id_pacijenta")>
			<cfset id_pacijenta = #Val(form.id_pacijenta)#>
		</cfif>

		<cfset id_epizode = 0>
		<cfif IsDefined("URL.id_epizode")>
			<cfset id_epizode = #Val(URL.id_epizode)#>
		<cfelseif IsDefined("form.id_epizode")>
			<cfset id_epizode = #Val(form.id_epizode)#>
		</cfif>
		
		<cfif (#id_pacijenta# not equal 0)>
			<cfinvoke component="#avar_relfolder#.rpc.main" method="pacijent_detalji" returnVariable="pacijent_detalji">
				<cfinvokeargument name="id_pacijenta" value="#id_pacijenta#">
			</cfinvoke>
			<cfif (#pacijent_detalji.recordCount# eq 1)>
				<cfif (#id_epizode# eq 0)>
					<cfset id_epizode = #Val(pacijent_detalji.id_epizode[1])#>
				</cfif>
			<cfelse>
				<cfset greska = 1>
				<cfset poruka = poruka & "Pacijent nije pronađen.<br />">
			</cfif>
		<cfelse>
			<cfset greska = 1>
			<cfset poruka = poruka & "Pacijent nije definisan.<br />">
		</cfif>

		<cfset jedinica = "">
		<cfset ref_vrijednosti = "">
		<cfset regular_expression = "">

		<cfset id_vrste = 0>
		<cfif IsDefined("form.id_vrste")>
			<cfset id_vrste = #Val(form.id_vrste)#>
		<cfelseif IsDefined("URL.id_vrste")>
			<cfset id_vrste = #Val(URL.id_vrste)#>
		</cfif>
		
		<cfif (#id_vrste# not equal 0)>
			<cfquery name="detalji_vrste" datasource="#SESSION.baza_podataka#">
				SELECT 
					ttd_lista_vrste.d_jedinica, 
					ttd_lista_vrste.d_ref_vrijednosti, 
					ttd_lista_vrste.d_regexp 
				FROM ttd_lista_vrste 
				WHERE ttd_lista_vrste.id = #id_vrste#
			</cfquery>
			<cfif (#detalji_vrste.recordCount# eq 1)>
				<cfset jedinica = #detalji_vrste.d_jedinica[1]#>
				<cfset ref_vrijednosti = #detalji_vrste.d_ref_vrijednosti[1]#>
				<cfset regular_expression = #detalji_vrste.d_regexp[1]#>
			</cfif>
		<cfelse>
			<cfset greska = 1>
			<cfset poruka = poruka & "Vrsta stavke nije definisana.<br />">
		</cfif>

		<cfset datum = DateFormat(now(),"yyyy-mm-dd")>
		<cfif IsDefined("form.datum")>
			<cfset datum = DatumKonverzija(form.datum)>
		<cfelseif IsDefined("URL.datum")>
			<cfset datum = DatumKonverzija(URL.datum)>
		</cfif>

		<cfset vrijeme = TimeFormat(now(),"HH:mm")>
		<cfif IsDefined("form.vrijeme")>
			<cfset vrijeme = #form.vrijeme#>
		<cfelseif IsDefined("URL.vrijeme")>
			<cfset vrijeme =  #UrlDecode(URL.vrijeme)#>
		</cfif>

		<cfif IsDate(vrijeme)>
			<cfset datum = datum & " " & #vrijeme# & ":00">
			<cfif (IsDate(datum) eq False)>
				<cfset greska = 1>
				<cfset poruka = poruka & "Niste pravilno upisali datum (" & #datum# & ") i vrijeme (" & #vrijeme# & ").<br />">
			</cfif>
		<cfelse>
			<cfset greska = 1>
			<cfset poruka = poruka & "Niste pravilno upisali vrijeme.<br />">
		</cfif>

		<cfset tmp_datum = DatumVrijemeSQL()>

		<cfset napomena = "">
		<cfif IsDefined("form.napomena")>
			<cfset napomena = #form.napomena#>
		<cfelseif IsDefined("URL.napomena")>
			<cfset napomena = #URL.napomena#>
		</cfif>
			
		<cfset kolicina = "NULL">
		<cfset kolicina_org = "">
		<cfif IsDefined("form.kolicina")>
			<cfset kolicina = #Val(form.kolicina)#>
			<cfset kolicina_org = #form.kolicina#>
		<cfelseif IsDefined("URL.kolicina")>
			<cfset kolicina = #Val(URL.kolicina)#>
			<cfset kolicina_org = #URL.kolicina#>
		</cfif>

		<cfset id_ref = "NULL">
		<cfif IsDefined("form.id_ref")>
			<cfset id_ref = #Val(form.id_ref)#>
		<cfelseif IsDefined("URL.id_ref")>
			<cfset id_ref = #Val(URL.id_ref)#>
		</cfif>
			
		<cfset vrijednost = "NULL">
		<cfif IsDefined("form.vrijednost")>
			<cfset vrijednost = #form.vrijednost#>
		<cfelseif IsDefined("URL.vrijednost")>
			<cfset vrijednost = #URL.vrijednost#>
		</cfif>

		<cfset vrijednost1 = "NULL">
		<cfif IsDefined("form.vrijednost1")>
			<cfset vrijednost1 = #form.vrijednost1#>
		<cfelseif IsDefined("URL.vrijednost1")>
			<cfset vrijednost1 = #URL.vrijednost1#>
		</cfif>

		<cfset vrijednost2 = "NULL">
		<cfif IsDefined("form.vrijednost2")>
			<cfset vrijednost2 = #form.vrijednost2#>
		<cfelseif IsDefined("URL.vrijednost2")>
			<cfset vrijednost2 = #URL.vrijednost2#>
		</cfif>

		<cfset realizacija = 0>
		<cfif IsDefined("form.realizacija")>
			<cfset realizacija = 1>
		<cfelseif IsDefined("URL.realizacija")>
			<cfset realizacija = #Val(URL.realizacija)#>
		</cfif>

		<cfset razduzenje = 0>
		<cfif IsDefined("form.razduzenje")>
			<cfset razduzenje = 1>
		<cfelseif IsDefined("URL.razduzenje")>
			<cfset razduzenje = #Val(URL.razduzenje)#>
		</cfif>

		<cfset kontinuirano = 0>
		<cfif IsDefined("form.kontinuirano")>
			<cfset kontinuirano = 1>
		<cfelseif IsDefined("URL.kontinuirano")>
			<cfset kontinuirano = #Val(URL.kontinuirano)#>
		</cfif>

		<cfset nacin_zakazivanja = 0>
		<cfif IsDefined("form.nacin_zakazivanja")>
			<cfset nacin_zakazivanja = #Val(form.nacin_zakazivanja)#>
		<cfelseif IsDefined("URL.nacin_zakazivanja")>
			<cfset nacin_zakazivanja = #Val(URL.nacin_zakazivanja)#>
		</cfif>

		<cfset broj_sati = 0>
		<cfif IsDefined("form.broj_sati")>
			<cfset broj_sati = #Val(form.broj_sati)#>
		<cfelseif IsDefined("URL.broj_sati")>
			<cfset broj_sati = #Val(URL.broj_sati)#>
		</cfif>
		<cfif (#broj_sati# LTE 0)>
			<cfset broj_sati = 8>
		</cfif>
		<!---<cfif (#broj_sati# LTE 0) AND (#nacin_zakazivanja# not equal 1))>
			<cfset greska = 1>
			<cfset poruka = poruka & "Niste definisali broj sati ponavljanja.<br />">
		</cfif>--->

		<!--- terapija --->
		<cfif (#id_vrste# eq 3)>
			<cfif ((#id_ref# eq "") OR ((#vrijednost# eq "") AND (#id_ref# not equal "")))>
				<cfset greska = 1>
				<cfset poruka = poruka & "Niste definisali lijek za terapiju.<br />">
			</cfif>
			<cfif (IsNumeric(kolicina_org) eq False)>
				<cfset greska = 1>
				<cfset poruka = poruka & "Niste pravilno upisali količinu lijeka.<br />">
			</cfif>
		<!--- temperatura --->
		<cfelseif (#id_vrste# eq 5)>
			<cfif IsNumeric(vrijednost)>
				<cfset vrijednost = #Val(vrijednost)#>
			<cfelse>
				<cfset vrijednost = "">
			</cfif>
		<!--- arterijski pritisak --->
		<cfelseif (#id_vrste# eq 6)>
			<cfif IsNumeric(vrijednost1) AND IsNumeric(vrijednost2)>
					<cfset vrijednost = #Val(vrijednost1)# & "/" & #Val(vrijednost2)#>
			<cfelseif (IsNumeric(vrijednost1) AND (IsNumeric(vrijednost2) eq False))>
					<cfset greska = 1>
					<cfset poruka = poruka & "Niste pravilno upisali vrijednost dijastolnog pritiska.<br />">
			<cfelseif (IsNumeric(vrijednost2) AND (IsNumeric(vrijednost1) eq False))>
				<cfset greska = 1>
				<cfset poruka = poruka & "Niste pravilno upisali vrijednost sistolnog pritiska.<br />">
			<cfelse>
				<cfset vrijednost = "">
			</cfif>
		<!--- puls --->
		<cfelseif (#id_vrste# eq 7)>
			<cfif IsNumeric(vrijednost)>
				<cfset vrijednost = #Val(vrijednost)#>
			<cfelse>
				<cfset vrijednost = "">
			</cfif>
		<!--- dijeta --->
		<cfelseif (#id_vrste# eq 10)>
			<cfif ((#id_ref# eq "") OR ((#vrijednost# eq "") AND (#id_ref# not equal "")))>
				<cfset greska = 1>
				<cfset poruka = poruka & "Niste definisali dijetu.<br />">
			</cfif>
			<cfif (IsNumeric(kolicina_org) eq False)>
				<cfset greska = 1>
				<cfset poruka = poruka & "Niste pravilno upisali količinu.<br />">
			</cfif>
		<!--- zapažanja --->
		<cfelseif (#id_vrste# eq 13)>
			<cfif (#vrijednost# eq "")>
				<cfset greska = 1>
				<cfset poruka = poruka & "Niste upisali opis zapažanja.<br />">
			</cfif>
		<!--- zadatak --->
		<cfelseif (#id_vrste# eq 14)>

		<!--- dijagnostika --->
		<cfelseif (#id_vrste# eq 15)>
			<cfif ((#id_ref# eq "") OR ((#vrijednost# eq "") AND (#id_ref# not equal "")))>
				<cfset greska = 1>
				<cfset poruka = poruka & "Niste definisali dijagnostičku proceduru.<br />">
			</cfif>
			<cfset kolicina = "NULL">
		<cfelse>
			<cfset id_ref = "NULL">
			<cfset kolicina = "NULL">
		</cfif>

		<cfif (#greska# eq 0)>

			<cfset status = 0>
			<cfif ((#id_vrste# eq 3) OR (#id_vrste# eq 15) OR (#id_vrste# eq 14))>
            	<cfset status = #realizacija#>
			<cfelseif (#vrijednost# not equal "")>
				<cfset status = 1>
			</cfif>

			<cftransaction>
				<!--- unos stavke --->
				<cfif (#id_stavke# eq "")>
					<cflock name="unos_todo" timeout="30">
						<cfset id_stavke = sljedeci_broj_kolone("ttd_lista_sadrzaj_detalji", "id")>
						<cfquery name="unos_stavke" datasource="#SESSION.baza_podataka#">
							INSERT INTO ttd_lista_sadrzaj_detalji(id, id_pacijenta, id_epizode, id_vrste, id_ref, datum, kolicina, vrijednost, jedinica, ref_vrijednosti, 
							regular_expression, id_kreirao, id_izmjenio, status, status_promjena, ponavljanje, ponavljanje_id, obrisano, napomena) 
							VALUES(#id_stavke#, #Val(id_pacijenta)#, #Val(id_epizode)#, #Val(id_vrste)#, #Val(id_ref)#, '#datum#', #kolicina#, '#vrijednost#', '#jedinica#',
							'#ref_vrijednosti#', '#regular_expression#', #SESSION.id_korisnika#, #SESSION.id_korisnika#, #status#, '#tmp_datum#', #kontinuirano#, NULL, 0, '#napomena#')
						</cfquery>
					</cflock>

					<!--- zakazivanje termina --->
                    <cfif (#nacin_zakazivanja# not equal 1)>
						<cfif ((#id_vrste# eq 3) OR (#id_vrste# eq 10))>
						<cfelse>
							<cfset vrijednost = "">
							<cfset kolicina = "NULL">
							<cfset id_ref = "NULL">
						</cfif>

						<cfset krajnji_termin = DateFormat(DateAdd('d', 1, datum), "yyyy-mm-dd") & " 00:00:00">
						<cfset datum_termin = DateAdd('h', broj_sati, datum)>
						<cfset datum_termin = DateFormat(datum_termin, "yyyy-mm-dd") & " " & TimeFormat(datum_termin, "HH:mm:ss")>

						<cfset zakazivanje_izlaz = 0>
						<cfset zakazivanje_broj_pokusaja = 0>
						<cfif (#nacin_zakazivanja# GTE 2)>
							<cfset zakazivanje_broj_pokusaja = #nacin_zakazivanja# - 1>
						</cfif>
						<cfset datum_poredjenje = DateCompare(datum_termin, krajnji_termin, "s")>

						<cfif (#datum_poredjenje# eq 1)>
							<cfset zakazivanje_izlaz = 1>
						</cfif>
						<cfif ((#nacin_zakazivanja# GTE 2) AND (#zakazivanje_broj_pokusaja# eq 0))>
							<cfset zakazivanje_izlaz = 1>
						</cfif>

						<cfloop condition="zakazivanje_izlaz eq 0">
							<cflock name="unos_todo" timeout="30">
								<cfset id_stavke = sljedeci_broj_kolone("ttd_lista_sadrzaj_detalji", "id")>
								<cfquery name="unos_stavke" datasource="#SESSION.baza_podataka#">
									INSERT INTO ttd_lista_sadrzaj_detalji(id, id_pacijenta, id_epizode, id_vrste, id_ref, datum, kolicina, vrijednost, jedinica, ref_vrijednosti, 
                    			    regular_expression, id_kreirao, id_izmjenio, status, status_promjena, ponavljanje, ponavljanje_id, obrisano, napomena) 
									VALUES(#id_stavke#, #id_pacijenta#, #id_epizode#, #id_vrste#, #id_ref#, '#datum_termin#', #kolicina#, '#vrijednost#',  '#jedinica#',
									'#ref_vrijednosti#', '#regular_expression#', #SESSION.id_korisnika#, NULL, 0, NULL, #kontinuirano#, #id_stavke#, 0, '#napomena#')
								</cfquery>
							</cflock>
							<cfset datum_termin = DateAdd('h', broj_sati, datum_termin)>
							<cfset datum_termin = DateFormat(datum_termin, "yyyy-mm-dd") & " " & TimeFormat(datum_termin, "HH:mm:ss")>
							<cfset datum_poredjenje = DateCompare(datum_termin, krajnji_termin, "s")>

							<cfif (#datum_poredjenje# eq 1)>
								<cfset zakazivanje_izlaz = 1>
							</cfif>
							<cfif (#nacin_zakazivanja# GTE 2)>
								<cfset zakazivanje_broj_pokusaja = #zakazivanje_broj_pokusaja# - 1>
								<cfif (#zakazivanje_broj_pokusaja# eq 0)>
									<cfset zakazivanje_izlaz = 1>
								</cfif>
							</cfif>
						</cfloop>
					</cfif>



				<!--- update stavke --->
				<cfelse>
					<cfquery name="detalji_stavke" datasource="#SESSION.baza_podataka#">
						SELECT * FROM ttd_lista_sadrzaj_detalji WHERE id = #id_stavke#
					</cfquery>
					<cfif (#detalji_stavke.recordCount# eq 1)>
						<cfif (#detalji_stavke.status[1]# eq 1)>
							<!--- samo korisnik koji je check-irao stavku ima ovlastenje da je naknadno mijenja 
							<cfif (#detalji_stavke.id_izmjenio[1]# not equal #SESSION.id_korisnika#)>
								<cfset greska = 1>
								<cfset poruka = poruka & "Nemate ovlaštenje da mijenjate stavku.<br />">
							</cfif> --->
							<!--- 1 dan dozvoljena izmjena stavke, izmjeniti kasnije 
							<cfif (#DateCompare(now(), detalji_stavke.status_promjena[1], "d")# eq 1)>
								<cfset greska = 1>
								<cfset poruka = poruka & "Nemate ovlaštenje da mijenjate stavke od prethodnog dana.<br />">
							</cfif> --->
						</cfif>
					<cfelse>
						<cfset greska = 1>
						<cfset poruka = poruka & "Stavka nije pronađena.<br />">
					</cfif>
					<cfif (#greska# eq 0)>
						<cfquery name="update_stavke" datasource="#SESSION.baza_podataka#">
							UPDATE ttd_lista_sadrzaj_detalji 
							SET 
								id_vrste = #Val(id_vrste)#, 
								id_ref = #Val(id_ref)#, 
								datum = '#datum#', 
								<cfif (#IsDefined("detalji_stavke.status[1]")# eq 1)>
									<cfif (#detalji_stavke.status[1]# eq 0)>
										kolicina = #kolicina#, 
									</cfif>
								</cfif>
								vrijednost = '#vrijednost#', 
								id_izmjenio = #SESSION.id_korisnika#,
								status = #status#, 
								status_promjena = '#tmp_datum#', 
								ponavljanje = #kontinuirano#, 
								napomena = '#napomena#' 
							WHERE id = #id_stavke#
						</cfquery>
					</cfif>
				</cfif>

		
				<!--- razduzuje proizvod --->
				<cfif ((#id_vrste# eq 3) OR (#id_vrste# eq 10))>
					<cfif (#razduzenje# eq 1)>
						<!---
						<cfinvoke component="#avar_relfolder#.rpc.main" method="izdaj_proizvod" returnvariable="izdaj_proizvod_odgovor" timeout="30">
							<cfinvokeargument name="skladiste_grupa" value="#SESSION.organizacija#">
							<cfinvokeargument name="skladiste" value="#SESSION.organizacija_odjel#">
							<cfinvokeargument name="id_korisnika" value="#SESSION.id_korisnika#">
							<cfinvokeargument name="id_pacijenta" value="#Val(id_pacijenta)#">
							<cfinvokeargument name="id_epizode" value="#Val(id_epizode)#">
							<cfinvokeargument name="id_proizvoda" value="#Val(id_ref)#">
							<cfinvokeargument name="kolicina" value="#Val(kolicina)#">
							<cfinvokeargument name="ID_transakcije" value="ttd_#id_stavke#">
							<cfinvokeargument name="omoguci_minus" value="1">
							<cfinvokeargument name="vrsta_transakcije" value="1">
							<cfinvokeargument name="napomena" value="">
						</cfinvoke>
						--->
					</cfif>
				</cfif>

			</cftransaction>	
		</cfif>

	</cfif>
	<cfcatch type="any">
		<cfset greska = 1>
		<cfset poruka = "GREŠKA: " & #Replace(cfcatch.Message,'"','','all')# & ". " & #Replace(cfcatch.detail,'"','','all')#>
	</cfcatch>
</cftry>

<response>
<cfoutput>
<greska>#Val(greska)#</greska>
<poruka>#XMLFormat(poruka)#</poruka>
</cfoutput>
</response>
</cfprocessingdirective>
