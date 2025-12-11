<cfcomponent displayname="apoteka_otpremnice">

	<cfinclude template="../cffunkcije.cfm">





	<cffunction name="faktura_pomocna_detalji_lista" returntype="query">
		<cfargument name="ID_dokumenta" type="string" required="yes" default="">
		<cfargument name="baza_podataka" type="string" required="yes" default="">
	
			<cfquery name="detalji_fakture" datasource="#arguments.baza_podataka#">	
				SELECT * 
				FROM faktura_pomocna_detalji
				WHERE ID_fakture = '#arguments.ID_dokumenta#'
			</cfquery>
			
			<cfreturn detalji_fakture>
	</cffunction>





	<cffunction name="faktura_pomocna_detalji_unesi"  returntype="struct" >
		<cfargument name="lista_proizvoda_query" type="query" required="no">
		<cfargument name="ID_dokumenta" type="string" required="no" default="">
		<cfargument name="baza_podataka" type="string" required="yes" default="">
		<cfargument name="skladiste_grupa" type="string" required="yes" default="">
		<cfargument name="skladiste" type="string" required="yes" default="">
		<cfset var poruka = "">
		<cfset var odgovor = StructNew()>
			
			<cfif IsQuery(arguments.lista_proizvoda_query)>
				 <cfloop query="arguments.lista_proizvoda_query">
					<cfset rok_stavke = "NULL">
					<cfset skladiste_grupa_stavke = 0>
					<cfset skladiste_stavke = 0>
					<cfset ID_dokumenta_za_unos = 0>
					
					<cfif IsDefined('arguments.lista_proizvoda_query.ID_fakture')>
						<cfset ID_dokumenta_za_unos = arguments.lista_proizvoda_query.ID_fakture>
					</cfif>
					<cfif IsDefined('arguments.lista_proizvoda_query.ID_dokumenta')>
						<cfset ID_dokumenta_za_unos = arguments.lista_proizvoda_query.ID_dokumenta>
					</cfif>
					
					<cfif arguments.ID_dokumenta not equal "">
						<cfset ID_dokumenta_za_unos = arguments.ID_dokumenta>
					</cfif>
					
					<cfif (Val(arguments.skladiste_grupa) not equal 0)>
						<cfset skladiste_grupa_stavke = Val(arguments.skladiste_grupa)>
					<cfelseif IsDefined('arguments.lista_proizvoda_query.skladiste_grupa')>
						<cfset skladiste_grupa_stavke = arguments.lista_proizvoda_query.skladiste_grupa>
					</cfif>

					<cfif (Val(arguments.skladiste) not equal 0)>
						<cfset skladiste_stavke = Val(arguments.skladiste)>
					<cfelseif IsDefined('arguments.lista_proizvoda_query.skladiste')>
						<cfset skladiste_stavke = arguments.lista_proizvoda_query.skladiste>
					</cfif>
					
					<cfif IsDate(arguments.lista_proizvoda_query.rok_upotrebe)>
						<cfset rok_stavke =  #DateFormat(arguments.lista_proizvoda_query.rok_upotrebe,"yyyy-mm-dd")#>
					</cfif>	
					
					<cfif (Val(skladiste_grupa_stavke) not equal 0) AND (Val(skladiste_stavke) not equal 0)>
						<cfquery name="Unesi_stavku" datasource="#arguments.baza_podataka#" result="Unesi_stavku_result">	
							INSERT INTO faktura_pomocna_detalji(
								ID, 
								ID_fakture, 
								sifra_proizvoda, 
								id_proizvoda, 
								kulaz, 
								FC, 
								rab, 
								porez, 
								marza, 
								mpc, 
								serija, 
								rok_upotrebe, 
								skladiste_grupa, 
								skladiste
							)
							VALUES(
								'#Slucajni_Broj()#', 
								'#ID_dokumenta_za_unos#', 
								'#arguments.lista_proizvoda_query.sifra_proizvoda#', 
								#Val(arguments.lista_proizvoda_query.id_proizvoda)#, 
								#Val(arguments.lista_proizvoda_query.kulaz)#, 
								#Val(arguments.lista_proizvoda_query.FC)#, 
								#Val(arguments.lista_proizvoda_query.rab)#, 
								#Val(arguments.lista_proizvoda_query.porez)#, 
								#Val(arguments.lista_proizvoda_query.marza)#, 
								#arguments.lista_proizvoda_query.mpc#, 
								'#arguments.lista_proizvoda_query.serija#', 
								#rok_stavke#, 
								#Val(skladiste_grupa_stavke)#, 
								#Val(skladiste_stavke)#
							)
						</cfquery>
					</cfif>
				 </cfloop>
			 </cfif>
			 <cfset odgovor.arguments = arguments>
			 <cfreturn odgovor>
	</cffunction>





	<cffunction name="proizvodi_stanje_generisi" returntype="struct" access="remote">
		<cfset var update_result = StructNew()>
		<cfset var tmp_log = StructNew()>
		<cfset var response = StructNew()>
		<cfset response.error = 0>
		<cfset response.message = "">
		
		<cftry>
			<cfset update_result = proizvodi_stanje_update(id_proizvoda='', skladiste_grupa=0, skladiste=0, baza_podataka='kiss')>
			<cfif (update_result.error eq 1)>
				<cfset response.error = 1>
				<cfset response.message = response.message & update_result.message>
			</cfif>
			<cfset tmp_log = Upisi_log('rebulid stanja', '', response.message)>
			
			<cfcatch type="any">
				<cfset response.error = 1>
				<cfset response.message = cfcatch.Message & ". " & cfcatch.detail>
			</cfcatch>
		</cftry>
	</cffunction>





	<cffunction name="proizvodi_stanje_update" returntype="struct" access="remote">
		<cfargument name="id_proizvoda" type="string" required="no" default="">
		<cfargument name="skladiste_grupa" type="string" required="no" default="">
		<cfargument name="skladiste" type="string" required="no" default="">
		<cfargument name="baza_podataka" type="string" required="no" default="">
		<cfset var red_broj = 1>
		<cfset var response = StructNew()>
		<cfset response.error = 0>
		<cfset response.message = "">
		
		<cfif (arguments.baza_podataka eq "")>
			<cfif IsDefined("SESSION.baza_podataka")>
				<cfset arguments.baza_podataka = SESSION.baza_podataka>
			<cfelse>
				<cfset response.error = 1>
				<cfset response.message = "Nije definisana baza podataka. ">
			</cfif>
		</cfif>

		<cfif (response.error eq 0)>
			<cflock name="proizvodi_stanje_update" timeout="60">
			<cftry>
				<!--- kompletan rebuild --->
				<cfif ((arguments.id_proizvoda eq "") AND (Val(arguments.skladiste_grupa) eq 0) AND (Val(arguments.skladiste) eq 0))>
					<cftransaction>
						<cfquery name="ciscenje_tabele" datasource="#arguments.baza_podataka#">
							TRUNCATE proizvodi_stanje 
						</cfquery>
						
						<cfquery name="insert_artikla" datasource="#arguments.baza_podataka#">
							INSERT INTO proizvodi_stanje (
								id_proizvoda,
								skladiste_grupa,
								skladiste,
								stanje
							)
							SELECT 
								detalji_podaci.id_proizvoda,
								detalji_podaci.skladiste_grupa,
								detalji_podaci.skladiste,
								IFNULL(SUM(detalji_podaci.kulaz-detalji_podaci.kizlaz),0) AS stanje 
							FROM detalji_podaci 
							<!--- WHERE ((detalji_podaci.kulaz <> 0) OR (detalji_podaci.kizlaz <> 0)) --->
							GROUP BY detalji_podaci.id_proizvoda, detalji_podaci.skladiste_grupa, detalji_podaci.skladiste
						</cfquery>
					</cftransaction>

				<!--- parcijalni rebuild --->
				<cfelse>
					<cfquery name="lista_artikala" datasource="#arguments.baza_podataka#">
						SELECT 
							detalji_podaci.id_proizvoda,
							detalji_podaci.skladiste_grupa,
							detalji_podaci.skladiste,
							IFNULL(SUM(detalji_podaci.kulaz-detalji_podaci.kizlaz),0) AS stanje 
						FROM detalji_podaci 
						WHERE 1 = 1 
						<cfif (arguments.id_proizvoda not equal "")>
							AND detalji_podaci.id_proizvoda IN (#arguments.id_proizvoda#) 
						</cfif>
						<cfif (Val(arguments.skladiste_grupa) not equal 0)>
							AND detalji_podaci.skladiste_grupa = #Val(arguments.skladiste_grupa)#
						</cfif>
						<cfif (Val(arguments.skladiste) not equal 0)>
							AND detalji_podaci.skladiste = #Val(arguments.skladiste)#
						</cfif>
						<!--- AND ((detalji_podaci.kulaz <> 0) OR (detalji_podaci.kizlaz <> 0)) --->
						GROUP BY detalji_podaci.id_proizvoda, detalji_podaci.skladiste_grupa, detalji_podaci.skladiste
					</cfquery>
					
					<cfif (lista_artikala.recordCount GTE 1)>
						<cftransaction>
							<cfquery name="brisanje_artikla" datasource="#arguments.baza_podataka#">
								DELETE 
								FROM proizvodi_stanje 
								WHERE 1 = 1 
								<cfif (arguments.id_proizvoda not equal "")>
									AND proizvodi_stanje.id_proizvoda IN (#arguments.id_proizvoda#) 
								</cfif>
								<cfif (Val(arguments.skladiste_grupa) not equal 0)>
									AND proizvodi_stanje.skladiste_grupa = #Val(arguments.skladiste_grupa)#
								</cfif>
								<cfif (Val(arguments.skladiste) not equal 0)>
									AND proizvodi_stanje.skladiste = #Val(arguments.skladiste)#
								</cfif>
							</cfquery>
					
							<cfloop condition="#red_broj# LTE #lista_artikala.recordCount#">
								<cfquery name="insert_artikla" datasource="#arguments.baza_podataka#">
									INSERT INTO proizvodi_stanje (
										id_proizvoda,
										skladiste_grupa,
										skladiste,
										stanje
									)
									VALUES 
									<cfloop query="lista_artikala" startrow="#red_broj#" endrow="#red_broj+19#">
										<cfif (lista_artikala.currentRow not equal red_broj)>, </cfif>
										(#Val(lista_artikala.id_proizvoda)#, #Val(lista_artikala.skladiste_grupa)#, #Val(lista_artikala.skladiste)#, #Val(lista_artikala.stanje)#)
									</cfloop>
								</cfquery>
								<cfset red_broj = red_broj + 20>
							</cfloop>
						</cftransaction>
					</cfif>
				</cfif>
	
				<cfcatch type="any">
					<cfset response.error = 1>
					<cfset response.message = cfcatch.Message & ". " & cfcatch.detail>
				</cfcatch>
			</cftry>
			</cflock>
		</cfif>
		
		<cfreturn response>
	</cffunction>


</cfcomponent>
