<cfcomponent displayname="main" output="false">

	<!--- apsolutna putanja za slike, popraviti i u podfolderu, application.cfm--->
	<cfset putanja_slika = "/opt/openbd/tomcat/webapps/ROOT/kis/bisa_2/slike/">

	<!--- baza podataka --->
	<cfif (IsDefined("SESSION.Baza_podataka") eq False)>
		<cfset SESSION.Baza_podataka = "kiss">
	</cfif>
	<cfif (IsDefined("avar_baza_podataka_conf") eq False)>
		<cfset avar_baza_podataka_conf = "kiss">
	</cfif>

	<cfset avar_relfolder = "kis">

	<cfinclude template="../cffunkcije.cfm">	





		<cffunction name="pacijent_detalji" access="remote" returntype="query">
			<cfargument name="id_pacijenta" type="numeric">
				<cfquery name="pacijent_detalji" datasource="#SESSION.Baza_podataka#" maxrows="1">
					SELECT 
						pacijenti.id, 
						pacijenti.prezime, 
						pacijenti.ime, 
						pacijenti.ime_roditelja, 
						pacijenti.jmbg,
						pacijenti.pol AS pol_sifra,
						pacijenti_pol.naziv AS pol, 
						Date(pacijenti.datum_rodjenja) AS datum_rodjenja,
						pacijenti.mjesto_rodjenja,
						pacijenti.adresa AS adresa_stanovanja, 
						pacijenti.mjesto AS mjesto_stanovanja,
						pacijenti.opstina_id, 
						COALESCE(opstine.naziv,'') AS naziv_opstine,
						COALESCE(pacijenti.opstina,'') AS naziv_opstine_ostalo, 

						krvne_grupe.naziv AS krvna_grupa, 
						pacijenti.rh_faktor, 

						pacijenti_bracno_stanje.naziv AS bracno_stanje,
						COALESCE(pacijenti.zanimanje,'') AS zanimanje, 
						pacijenti.broj_kartona, 
						pacijenti.datum_smrti, 
						pacijenti.razlog_smrti, 
						pacijenti.telefon,
						pacijenti.email,
						pacijenti.napomena,

						pacijenti.id_epizode, 
						epizoda.broj_epizode AS epizoda_broj,
						epizoda.datum_od,
						epizoda.epizoda_vrsta_id, 
						epizoda_vrsta.naziv AS epizoda_naziv_vrste,
						epizoda.id_uputnice,
						epizoda.tip_uputnice,
						epizoda.vid_osiguranja, 
						epizoda.uputna_dijagnoza, 
						epizoda.ustanova_sifra,
						epizoda.ljekar_sifra, 
						epizoda.vrsta_prijema, 
						epizoda.maticni_broj, 
						epizoda.napomena AS epizoda_napomena,
						epizoda.skladiste_grupa, 
						epizoda.skladiste, 
						epizoda.id_ljekara,
						epizoda.ihe_uputnica_unique_id,
						epizoda.ihe_uputnica_tip,
						epizoda.ihe_uputnica_id_dokumenta,
						epizoda.ihe_uputnica_odgovor_id_dokumenta,
						epizoda.ihe_uputnica_odgovor_datum_slanja,
						epizoda.ihe_uputnica_odgovor_status,
						epizoda.ihe_uputnica_odgovor_unique_id,
						fond_ustanova.naziv AS ustanova_naziv,
						fond_doktor.ime AS ljekar_naziv,
						dijagnoza.imedijag AS uputna_dijagnoza_naziv,
						skladiste_grupa.naziv AS epizoda_klinika_naziv,
						skladiste.naziv AS epizoda_odjel_naziv,
						'' AS greska 
						FROM pacijenti 
						LEFT JOIN pacijenti_pol ON pacijenti_pol.id = pacijenti.pol 
						LEFT JOIN opstine ON opstine.id = pacijenti.opstina_id 
						LEFT JOIN krvne_grupe ON krvne_grupe.id = pacijenti.krvna_grupa 
						LEFT JOIN pacijenti_bracno_stanje ON pacijenti_bracno_stanje.id = pacijenti.bracno_stanje_id
						LEFT JOIN epizoda ON epizoda.id = pacijenti.id_epizode
						LEFT JOIN epizoda_vrsta ON epizoda_vrsta.id = epizoda.epizoda_vrsta_id	
						LEFT JOIN fond_ustanova ON fond_ustanova.sifra = epizoda.ustanova_sifra	
						LEFT JOIN fond_doktor ON fond_doktor.sifra = epizoda.ljekar_sifra 
						LEFT JOIN dijagnoza ON dijagnoza.sifradijag = epizoda.uputna_dijagnoza 
					LEFT JOIN skladiste_grupa ON skladiste_grupa.ID = epizoda.skladiste_grupa 
					LEFT JOIN skladiste ON skladiste.ID = epizoda.skladiste 
						WHERE pacijenti.id = #Val(id_pacijenta)#  
				</cfquery>
			<cfreturn pacijent_detalji>
		</cffunction>





		<cffunction name="pacijent_detalji_arhiva" access="remote" returntype="query">
			<cfargument name="id_pacijenta" type="numeric" required="yes" default="0">
			<cfargument name="datum_promjene" type="string" required="no" default="">
			<cfset var podaci_pacijenta = StructNew()>

			<cfquery name="pacijent_detaljiq" datasource="#SESSION.baza_podataka#">
				SELECT 
					p.* 
				FROM (
					SELECT 
						1 AS tabela_sort,
						pacijenti.id, 
						pacijenti.prezime, 
						pacijenti.ime, 
						pacijenti.ime_roditelja, 
						pacijenti.jmbg,
						pacijenti.pol AS pol_sifra,
						pacijenti_pol.naziv AS pol, 
						Date(pacijenti.datum_rodjenja) AS datum_rodjenja,
						pacijenti.mjesto_rodjenja,
						pacijenti.adresa AS adresa_stanovanja, 
						pacijenti.mjesto AS mjesto_stanovanja,
						pacijenti.opstina_id, 
						COALESCE(opstine.naziv,'') AS naziv_opstine,
						COALESCE(pacijenti.opstina,'') AS naziv_opstine_ostalo, 
	
						krvne_grupe.naziv AS krvna_grupa, 
						pacijenti.rh_faktor, 
	
						pacijenti_bracno_stanje.naziv AS bracno_stanje,
						COALESCE(pacijenti.zanimanje,'') AS zanimanje, 
						pacijenti.broj_kartona, 
						pacijenti.datum_smrti, 
						pacijenti.razlog_smrti, 
						pacijenti.telefon,
						pacijenti.email,
						pacijenti.napomena,
	
						pacijenti.id_epizode, 
						epizoda.broj_epizode AS epizoda_broj,
						epizoda.datum_od,
						epizoda.epizoda_vrsta_id, 
						epizoda_vrsta.naziv AS epizoda_naziv_vrste,
						epizoda.vid_osiguranja, 
						epizoda.uputna_dijagnoza, 
						epizoda.ustanova_sifra,
						epizoda.ljekar_sifra, 
						epizoda.vrsta_prijema, 
						epizoda.napomena AS epizoda_napomena,
						epizoda.skladiste_grupa, 
						epizoda.skladiste, 
						fond_ustanova.naziv AS ustanova_naziv,
						fond_doktor.ime AS ljekar_naziv,
						dijagnoza.imedijag AS uputna_dijagnoza_naziv,
						skladiste_grupa.naziv AS epizoda_klinika_naziv,
						skladiste.naziv AS epizoda_odjel_naziv,
						'' AS greska,
						pacijenti.datum_izmjene  
					FROM pacijenti 
					LEFT JOIN pacijenti_pol ON pacijenti_pol.id = pacijenti.pol 
					LEFT JOIN opstine ON opstine.id = pacijenti.opstina_id 
					LEFT JOIN krvne_grupe ON krvne_grupe.id = pacijenti.krvna_grupa 
					LEFT JOIN pacijenti_bracno_stanje ON pacijenti_bracno_stanje.id = pacijenti.bracno_stanje_id
					LEFT JOIN epizoda ON epizoda.id = pacijenti.id_epizode
					LEFT JOIN epizoda_vrsta ON epizoda_vrsta.id = epizoda.epizoda_vrsta_id					
					LEFT JOIN fond_ustanova ON fond_ustanova.sifra = epizoda.ustanova_sifra	
					LEFT JOIN fond_doktor ON fond_doktor.sifra = epizoda.ljekar_sifra 
					LEFT JOIN dijagnoza ON dijagnoza.sifradijag = epizoda.uputna_dijagnoza 
					LEFT JOIN skladiste_grupa ON skladiste_grupa.ID = epizoda.skladiste_grupa 
					LEFT JOIN skladiste ON skladiste.ID = epizoda.skladiste 			
					WHERE pacijenti.id = #Val(arguments.id_pacijenta)# 
					AND ((pacijenti.datum_izmjene <= '#arguments.datum_promjene#') OR (pacijenti.datum_izmjene IS NULL))
					
					UNION ALL 
					
					SELECT 
						0 AS tabela_sort,
						pacijenti_arhiva.id, 
						pacijenti_arhiva.prezime, 
						pacijenti_arhiva.ime, 
						pacijenti_arhiva.ime_roditelja, 
						pacijenti_arhiva.jmbg,
						pacijenti_arhiva.pol AS pol_sifra,
						pacijenti_pol.naziv AS pol, 
						Date(pacijenti_arhiva.datum_rodjenja) AS datum_rodjenja,
						pacijenti_arhiva.mjesto_rodjenja,
						pacijenti_arhiva.adresa AS adresa_stanovanja, 
						pacijenti_arhiva.mjesto AS mjesto_stanovanja,
						pacijenti_arhiva.opstina_id, 
						COALESCE(opstine.naziv,'') AS naziv_opstine,
						COALESCE(pacijenti_arhiva.opstina,'') AS naziv_opstine_ostalo, 
	
						krvne_grupe.naziv AS krvna_grupa, 
						pacijenti_arhiva.rh_faktor, 
	
						pacijenti_bracno_stanje.naziv AS bracno_stanje,
						COALESCE(pacijenti_arhiva.zanimanje,'') AS zanimanje, 
						pacijenti_arhiva.broj_kartona, 
						pacijenti_arhiva.datum_smrti, 
						pacijenti_arhiva.razlog_smrti, 
						pacijenti_arhiva.telefon,
						pacijenti_arhiva.email,
						pacijenti_arhiva.napomena,
	
						pacijenti_arhiva.id_epizode, 
						epizoda.broj_epizode AS epizoda_broj,
						epizoda.datum_od,
						epizoda.epizoda_vrsta_id, 
						epizoda_vrsta.naziv AS epizoda_naziv_vrste,
						epizoda.vid_osiguranja, 
						epizoda.uputna_dijagnoza, 
						epizoda.ustanova_sifra,
						epizoda.ljekar_sifra, 
						epizoda.vrsta_prijema, 
						epizoda.napomena AS epizoda_napomena,
						epizoda.skladiste_grupa, 
						epizoda.skladiste, 
						fond_ustanova.naziv AS ustanova_naziv,
						fond_doktor.ime AS ljekar_naziv,
						dijagnoza.imedijag AS uputna_dijagnoza_naziv,
						skladiste_grupa.naziv AS epizoda_klinika_naziv,
						skladiste.naziv AS epizoda_odjel_naziv,
						'' AS greska, 
						pacijenti_arhiva.datum_izmjene 
					FROM pacijenti_arhiva 
					LEFT JOIN pacijenti_pol ON pacijenti_pol.id = pacijenti_arhiva.pol 
					LEFT JOIN opstine ON opstine.id = pacijenti_arhiva.opstina_id 
					LEFT JOIN krvne_grupe ON krvne_grupe.id = pacijenti_arhiva.krvna_grupa 
					LEFT JOIN pacijenti_bracno_stanje ON pacijenti_bracno_stanje.id = pacijenti_arhiva.bracno_stanje_id
					LEFT JOIN epizoda ON epizoda.id = pacijenti_arhiva.id_epizode
					LEFT JOIN epizoda_vrsta ON epizoda_vrsta.id = epizoda.epizoda_vrsta_id					
					LEFT JOIN fond_ustanova ON fond_ustanova.sifra = epizoda.ustanova_sifra	
					LEFT JOIN fond_doktor ON fond_doktor.sifra = epizoda.ljekar_sifra 
					LEFT JOIN dijagnoza ON dijagnoza.sifradijag = epizoda.uputna_dijagnoza 
					LEFT JOIN skladiste_grupa ON skladiste_grupa.ID = epizoda.skladiste_grupa 
					LEFT JOIN skladiste ON skladiste.ID = epizoda.skladiste 				
					WHERE pacijenti_arhiva.id_pacijenta = #Val(arguments.id_pacijenta)# 
					AND ((pacijenti_arhiva.datum_izmjene <= '#arguments.datum_promjene#') OR (pacijenti_arhiva.datum_izmjene IS NULL))
				) AS p
				ORDER BY p.datum_izmjene DESC, p.tabela_sort DESC 
				LIMIT 1
			</cfquery>
			
			<cfif (pacijent_detaljiq.recordCount eq 0)>
				<cfset podaci_pacijenta = pacijent_detalji(Val(arguments.id_pacijenta))>
			<cfelse>
				<cfset podaci_pacijenta = pacijent_detaljiq>
			</cfif>

			<cfreturn podaci_pacijenta>
		</cffunction>





		<cffunction name="epizoda_detalji">
			<cfargument name="id_epizode" type="numeric">
			
			<cfquery name="epizoda_detalji" datasource="#SESSION.Baza_podataka#">
				SELECT 
					epizoda.id, 
					epizoda.broj_epizode, 
					epizoda.datum_od,
					epizoda.datum_do,
					epizoda.maticni_broj,
					epizoda.napomena,
					epizoda.proknjizeno,
					epizoda.epizoda_vrsta_id,
					epizoda.broj_bolnickih_dana,
					epizoda.opstina,
					epizoda.rbo,
					epizoda.djelatnost,
					epizoda.kat_osiguranja,
					epizoda.id_uputnice,
					epizoda.tip_uputnice,
					epizoda.vid_osiguranja,
					epizoda.uputna_dijagnoza,
					epizoda.ustanova_sifra,
					epizoda.ljekar_sifra,
					epizoda.vrsta_prijema,
					epizoda.oop,
					epizoda.osiguran_od,
					epizoda.osiguran_do,
					epizoda.status_osiguranja,
					epizoda.fond_cache_id,
					epizoda.skladiste_grupa,
					epizoda.skladiste,
					epizoda_vrsta.naziv AS naziv_vrste
				FROM epizoda
				LEFT JOIN epizoda_vrsta ON  epizoda_vrsta.id = epizoda.epizoda_vrsta_id
				WHERE epizoda.id = #id_epizode#
				ORDER BY id DESC
			</cfquery>
			<cfreturn epizoda_detalji>
		</cffunction>





		<cffunction name="epizoda_ucitaj" returntype="struct" access="remote">
			<cfargument name="id_epizode" type="string" required="yes">
			<cfargument name="id_pacijenta" type="string" required="yes">
			<cfset var odgovor = StructNew()>
			<cfset odgovor.greska = 0>
			<cfset odgovor.poruka = "">
			<cfset odgovor.data = "">
			
			<cftry>
				<cfif (Val(arguments.id_epizode) not equal 0)>
					<cfquery name="epizoda_detalji" datasource="#SESSION.Baza_podataka#">
						SELECT 
							epizoda.id, 
							epizoda.id_pacijenta, 
							epizoda.broj_epizode, 
							epizoda.datum_od,
							epizoda.datum_do,
							epizoda.maticni_broj,
							epizoda.napomena,
							epizoda.proknjizeno,
							epizoda.epizoda_vrsta_id,
							epizoda.broj_bolnickih_dana,
							epizoda.opstina,
							epizoda.rbo,
							epizoda.djelatnost,
							epizoda.kat_osiguranja,
							epizoda.id_uputnice,
							epizoda.tip_uputnice,
							epizoda.vid_osiguranja,
							epizoda.uputna_dijagnoza,
							epizoda.ustanova_sifra,
							epizoda.ljekar_sifra,
							epizoda.vrsta_prijema,
							epizoda.oop,
							epizoda.osiguran_od,
							epizoda.osiguran_do,
							epizoda.status_osiguranja,
							epizoda.fond_cache_id,
							epizoda.skladiste_grupa,
							epizoda.skladiste,
							epizoda.ihe_uputnica_unique_id,
							epizoda_vrsta.naziv AS naziv_vrste,
							fond_ustanova.naziv AS ustanova_naziv 
						FROM epizoda 
						LEFT JOIN epizoda_vrsta ON epizoda_vrsta.id = epizoda.epizoda_vrsta_id 
						LEFT JOIN fond_ustanova ON fond_ustanova.sifra = epizoda.ustanova_sifra	
						WHERE epizoda.id = #Val(arguments.id_epizode)#
					</cfquery>
				</cfif>
				
				<cfquery name="vrste_epizoda" datasource="#SESSION.Baza_podataka#">
					SELECT 
						epizoda_vrsta.id, 
						epizoda_vrsta.naziv 
					FROM epizoda_vrsta 
					ORDER BY epizoda_vrsta.id ASC
				</cfquery>
				
				<cfquery name="pacijent_detalji" datasource="#SESSION.Baza_podataka#">
					SELECT 
						pacijenti.id, 
						pacijenti.jmbg  
					FROM pacijenti 
					WHERE pacijenti.id = <cfif (Val(arguments.id_pacijenta) not equal 0)>#Val(arguments.id_pacijenta)#<cfelseif IsDefined("epizoda_detalji.id_pacijenta[1]")>#Val(epizoda_detalji.id_pacijenta[1])#<cfelse>0</cfif> 
				</cfquery>
				
				<cfsavecontent variable="odgovor.data">
					<cfprocessingdirective suppresswhitespace="yes">
						<cfoutput>
						<form name="form_epizoda" method="post" action="epizode_pacijenta_akcija.cfm">
							<input type="hidden" name="id" value="#Val(arguments.id_epizode)#" />
							<input type="hidden" name="id_pacijenta" value="#Val(arguments.id_pacijenta)#" />
							<input type="hidden" name="id_uputnice" value="<cfif IsDefined('epizoda_detalji.id_uputnice[1]')>#epizoda_detalji.id_uputnice[1]#</cfif>" />
							
							<cfset tmp_proknjizeno = 0>
							<cfif IsDefined("epizoda_detalji.proknjizeno[1]")>
								<cfset tmp_proknjizeno = Val(epizoda_detalji.proknjizeno[1])>
							</cfif>
							<input type="hidden" name="proknjizeno" value="#tmp_proknjizeno#" />
							
							<table border="0" cellpadding="0" cellspacing="0" class="fontbc" style="width:100%; border:none; text-align:left;">
								<cfset tmp_epizoda_vrsta_id = 0>
								<cfif IsDefined("epizoda_detalji.epizoda_vrsta_id[1]")>
									<cfset tmp_epizoda_vrsta_id = Val(epizoda_detalji.epizoda_vrsta_id[1])>
								</cfif>
								<tr>
									<td>vrsta epizode:</td>
									<td style="width:352px;">
										<select class="inputbox inp_select" name="epizoda_vrsta_id" style="width:auto;">
											<cfoutput query="vrste_epizoda">
												<option value="#vrste_epizoda.id#" <cfif (Val(tmp_epizoda_vrsta_id) eq Val(vrste_epizoda.id))>selected="selected"</cfif>>#vrste_epizoda.naziv#</option>
											</cfoutput>
										</select>
										<cfif IsDefined('pacijent_detalji.jmbg[1]')>
											<cfif (Len(pacijent_detalji.jmbg[1]) eq 13)>
												<input type="button" name="btn_online_uputnice" class="button" style="width:120px; float:right;" value="uputnice" onclick="pacijent_uputnice_provjera2('#pacijent_detalji.jmbg[1]#')" />
											</cfif>
										</cfif>
									</td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfset tmp_broj_epizode = "">
								<cfif IsDefined("epizoda_detalji.broj_epizode[1]")>
									<cfset tmp_broj_epizode = epizoda_detalji.broj_epizode[1]>
								</cfif>
								<tr>
									<td>broj protokola:</td>
									<td><input type="text" class="inputbox" name="broj_epizode" style="width:92px;" value="#tmp_broj_epizode#" /></td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								
								<cfset tmp_maticni_broj = "">
								<cfif IsDefined("epizoda_detalji.maticni_broj[1]")>
									<cfset tmp_maticni_broj = epizoda_detalji.maticni_broj[1]>
								</cfif>
								<tr>
									<td>matični broj:</td>
									<td><input type="text" class="inputbox" name="maticni_broj" style="width:99%;" value="#tmp_maticni_broj#" /></td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								
								<cfset tmp_tip_uputnice = "">
								<cfif IsDefined("epizoda_detalji.tip_uputnice[1]")>
									<cfset tmp_tip_uputnice = epizoda_detalji.tip_uputnice[1]>
								</cfif>
								<cfset bez_uputnice = 0>
								<cfif IsDefined("epizoda_detalji.skladiste_grupa[1]")>
									<cfif (Val(epizoda_detalji.skladiste_grupa[1]) eq 1182)>
										<cfset bez_uputnice = 1>
									</cfif>
								<cfelseif (Val(SESSION.organizacija) eq 1182)>
									<cfset bez_uputnice = 1>
								</cfif>
								<tr>
									<td>tip uputnice:</td>
									<td>
										<select name="tip_uputnice" class="inputbox inp_select" style="width:100%; text-transform:none;">
											<option value="">...</option>
											<cfif (bez_uputnice eq 1)>
												<option value="X" <cfif (tmp_tip_uputnice eq "X")>selected="selected"</cfif>>X - bez uputnice</option>
											</cfif>
											<option value="N" <cfif (tmp_tip_uputnice eq "N")>selected="selected"</cfif>>N - ostale uputnice</option>
											<option value="S" <cfif (tmp_tip_uputnice eq "S")>selected="selected"</cfif>>S - specijalistička uputnica</option>
											<option value="B" <cfif (tmp_tip_uputnice eq "B")>selected="selected"</cfif>>B - uputnica za bolničko liječenje</option>
										</select>
									</td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfset tmp_uputna_dijagnoza = "">
								<cfif IsDefined("epizoda_detalji.uputna_dijagnoza[1]")>
									<cfset tmp_uputna_dijagnoza = epizoda_detalji.uputna_dijagnoza[1]>
								</cfif>
								<tr>
									<td>uputna dg:</td>
									<td><input type="text" class="inputbox" name="uputna_dijagnoza" style="width:40px;" value="#tmp_uputna_dijagnoza#" onkeyup="g_uniajax_input_taster(event, this, '8','', '1', this)" /></td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfset tmp_vid_osiguranja = 0>
								<cfif IsDefined("epizoda_detalji.vid_osiguranja[1]")>
									<cfset tmp_vid_osiguranja = Val(epizoda_detalji.vid_osiguranja[1])>
								</cfif>
								<tr>
									<td>vid osiguranja:</td>
									<td>
										<select name="vid_osiguranja" class="inputbox inp_select" style="width:auto;">
											<option value="0" <cfif (tmp_vid_osiguranja eq 0)>selected="selected"</cfif>>NEOSIGURAN</option>
											<option value="1" <cfif (tmp_vid_osiguranja eq 1)>selected="selected"</cfif>>OB</option>
											<option value="6" <cfif (tmp_vid_osiguranja eq 6)>selected="selected"</cfif>>OZ</option>
										</select>
									</td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfset tmp_vrsta_prijema = 0>
								<cfif IsDefined("epizoda_detalji.vrsta_prijema[1]")>
									<cfset tmp_vrsta_prijema = #Val(epizoda_detalji.vrsta_prijema[1])#>
								</cfif>
								<input type="hidden" name="vrsta_prijema" value="#tmp_vrsta_prijema#">
								<!---
								<tr>
									<td>vrsta prijema:</td>
									<td>
										<select name="vrsta_prijema" class="inputbox inp_select" style="width:auto;">
											<option value="0" <cfif (tmp_vrsta_prijema eq 0)>selected="selected"</cfif>>REDOVAN</option>
											<option value="1" <cfif (tmp_vrsta_prijema eq 1)>selected="selected"</cfif>>HITAN</option>
										</select>
									</td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								--->
								<cfset tmp_ljekar_sifra = "">
								<cfif IsDefined("epizoda_detalji.ljekar_sifra[1]")>
									<cfset tmp_ljekar_sifra = #epizoda_detalji.ljekar_sifra[1]#>
								</cfif>
								<tr>
									<td>ljekar:</td>
									<td><input type="text" name="ljekar_sifra" class="inputbox" style="width:48px;" value="#tmp_ljekar_sifra#" onkeyup="g_uniajax_input_taster(event, this, '31','', '2','',this.form.ljekar_naziv,this.form.ustanova_sifra,this.form.ustanova_naziv)" placeholder="...šifra" /> <input type="text" class="inputbox inp_disabled" name="ljekar_naziv" style="width:292px;" value="<cfif IsDefined('epizoda_detalji.ljekar_naziv[1]')>#epizoda_detalji.ljekar_naziv[1]#</cfif>" onkeyup="g_uniajax_input_taster(event, this, '31', '', '1', this.form.ljekar_sifra, this.form.ljekar_naziv);" /></td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfset tmp_ustanova_sifra = "">
								<cfif IsDefined("epizoda_detalji.ustanova_sifra[1]")>
									<cfset tmp_ustanova_sifra = #epizoda_detalji.ustanova_sifra[1]#>
								</cfif>
								<tr>
									<td>ustanova:</td>
									<td><input type="text" name="ustanova_sifra" class="inputbox" style="width:48px;" value="#tmp_ustanova_sifra#" onkeyup="g_uniajax_input_taster(event, this, '30','', '1','',this.form.ustanova_naziv)" placeholder="...šifra" /> <input type="text" class="inputbox inp_disabled" name="ustanova_naziv" style="width:292px;" value="<cfif IsDefined('epizoda_detalji.ustanova_naziv[1]')>#epizoda_detalji.ustanova_naziv[1]#</cfif>" readonly="readonly" /></td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfset tmp_skladiste_grupa = 0>
								<cfif IsDefined("epizoda_detalji.skladiste_grupa[1]")>
									<cfset tmp_skladiste_grupa = Val(epizoda_detalji.skladiste_grupa[1])>
								</cfif>
								<cfquery name="lista_klinika" datasource="#SESSION.baza_podataka#">
									SELECT 
										skladiste_grupa.ID AS id,
										skladiste_grupa.naziv 
									FROM skladiste_grupa 
									WHERE skladiste_grupa.aktivno = 1 
									ORDER BY skladiste_grupa.ID ASC 
								</cfquery>
								<tr>
									<td>služba prijema:</td>
									<td>
										<select name="skladiste_grupa" class="inputbox inp_select" style="width:100%; text-transform:none;" onchange="g_uniajax_select(this,'32','',this.form.skladiste,'0','...')">
											<option value="0" <cfif (tmp_skladiste_grupa eq 0)>selected="selected"</cfif>>...</option>
											<cfloop query="lista_klinika">
												<option value="#lista_klinika.id#" <cfif (Val(lista_klinika.id) eq Val(tmp_skladiste_grupa))>selected="selected"</cfif>>#lista_klinika.id# #lista_klinika.naziv#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<cfset tmp_skladiste = 0>
								<cfif IsDefined("epizoda_detalji.skladiste[1]")>
									<cfset tmp_skladiste = Val(epizoda_detalji.skladiste[1])>
								</cfif>
								<cfquery name="lista_odjela" datasource="#SESSION.baza_podataka#">
									SELECT 
										skladiste.ID AS id,
										skladiste.naziv 
									FROM skladiste 
									WHERE skladiste.aktivno = 1 
									AND skladiste.ID_grupe = #Val(tmp_skladiste_grupa)#
									ORDER BY skladiste.ID ASC 
								</cfquery>
								<tr>
									<td>odjel prijema:</td>
									<td>
										<select name="skladiste" class="inputbox inp_select" style="width:100%; text-transform:none;" onkeyup="g_form_navigacija(event,this)">
											<option value="0" <cfif (tmp_skladiste eq 0)>selected="selected"</cfif>>...</option>
											<cfloop query="lista_odjela">
												<option value="#lista_odjela.id#" <cfif (Val(lista_odjela.id) eq Val(tmp_skladiste))>selected="selected"</cfif>>#lista_odjela.id# #lista_odjela.naziv#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfset tmp_datum_od = DateFormat(now(),"dd.mm.yyyy")>
								<cfif IsDefined("epizoda_detalji.datum_od[1]")>
									<cfset tmp_datum_od = DateFormat(epizoda_detalji.datum_od[1],"dd.mm.yyyy")>
								</cfif>
								<tr>
									<td>datum početka:</td>
									<td><input type="text" class="inputbox inp_date" name="datum_od" value="#tmp_datum_od#" onclick="displayDatePicker('datum_od', false, 'dmy', '.')" style="width:92px;"/></td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfset tmp_datum_do = "">
								<cfif IsDefined("epizoda_detalji.datum_do[1]")>
									<cfset tmp_datum_do = DateFormat(epizoda_detalji.datum_do[1],"dd.mm.yyyy")>
								</cfif>
								<tr>
									<td>datum završetka:</td>
									<td><input type="text" class="inputbox inp_date" name="datum_do" value="#tmp_datum_do#" onclick="displayDatePicker('datum_do', false, 'dmy', '.')" style="width:92px;"/></td>
								</tr>
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfset tmp_napomena = "">
								<cfif IsDefined("epizoda_detalji.napomena[1]")>
									<cfset tmp_napomena = epizoda_detalji.napomena[1]>
								</cfif>
								<tr>
									<td>napomena:</td>
									<td><textarea name="napomena" class="inputbox inp_textarea" style="width:350px;">#tmp_napomena#</textarea></td>
								</tr>
								<cfif (SESSION.id_korisnika eq 25) OR (SESSION.id_korisnika eq 1773)>
									<tr style="height:4px;">
										<td colspan="2"></td>
									</tr>
									<cfset tmp_ihe_id = "">
									<cfif IsDefined("epizoda_detalji.ihe_uputnica_unique_id[1]")>
										<cfset tmp_ihe_id = epizoda_detalji.ihe_uputnica_unique_id[1]>
									</cfif>
									<cfquery name="ihe_lista_uputnica" datasource="#SESSION.baza_podataka#">
										SELECT 
											dokumenti.datum_kreiranja,
											u.ihe_id 
										FROM (
											SELECT 
												dokumenti_detalji_char.id_dokumenta,
												dokumenti_detalji_char.vrijednost AS ihe_id
											FROM dokumenti_detalji_char 
											WHERE dokumenti_detalji_char.id_forme = 762 
											AND dokumenti_detalji_char.id_modula = 26491 
											AND dokumenti_detalji_char.aktivno = 1 
											AND dokumenti_detalji_char.vrijednost <> ''
											AND dokumenti_detalji_char.id_dokumenta IN (
												SELECT 
													dokumenti.id 
												FROM dokumenti 
												WHERE dokumenti.id_forme = 762
												AND dokumenti.id_pacijenta = #Val(arguments.id_pacijenta)# 
												AND dokumenti.obrisano = 0 
											)
										) AS u 
										LEFT JOIN dokumenti ON dokumenti.id = u.id_dokumenta
										ORDER BY dokumenti.datum_kreiranja DESC
									</cfquery>
									<tr>
										<td>IHE uputnica:</td>
										<td>
											<input type="hidden" name="ihe_uputnica_unique_id_trenutna" value="#tmp_ihe_id#" />
											<select name="ihe_uputnica_unique_id" class="inputbox inp_select" style="width:100%; text-transform:none;">
												<option value="" <cfif (tmp_ihe_id eq "")>selected="selected"</cfif>>BEZ IHE UPUTNICE</option>
												<cfloop query="ihe_lista_uputnica">
													<option value="#ihe_lista_uputnica.ihe_id#" <cfif (ihe_lista_uputnica.ihe_id eq tmp_ihe_id)>selected="selected"</cfif>>#ReplaceNoCase(ReplaceNoCase(ihe_lista_uputnica.ihe_id,"1.3.6.1.4.1.54469.3.6^","","all"),"1.3.6.1.4.1.54469.3.5^","","all")# | preuzeta: #DateFormat(ihe_lista_uputnica.datum_kreiranja,"dd.mm.yyyy")# #TimeFormat(ihe_lista_uputnica.datum_kreiranja,"HH:mm")#</option>
												</cfloop>
											</select>
										</td>
									</tr>
								</cfif>
								
								<tr style="height:4px;">
									<td colspan="2"></td>
								</tr>
								<cfif (tmp_proknjizeno eq 0)>
									<tr style="height:4px;">
										<td colspan="2"><hr /></td>
									</tr>
									<tr style="height:4px;">
										<td colspan="2"></td>
									</tr>
									<tr style="background:##CCC; font-weight:bold; text-align:center; text-transform:uppercase;">
										<td colspan="2">Zatvaranje epizode - potvrda:</td>
									</tr>
									<tr>
										<td colspan="2">
											<table border="0" cellpadding="0" cellspacing="0" style="width:100%; border:none; text-align:left;">
												<tr style="height:4px;">
													<td colspan="2"></td>
												</tr>
												<tr>
													<td style="width:24px;"><input type="checkbox" name="potvrda_unosa_dokumenta" onchange="otkljucaj_zakljucenje()"></td>
													<td>svi dokumenti uneseni i konačni!</td>
												</tr>
												<tr style="height:4px;">
													<td colspan="2"></td>
												</tr>
												<tr>
													<td><input type="checkbox" name="potvrda_unosa_potrosnje"  onchange="otkljucaj_zakljucenje()"></td>
													<td>sva potrosnja usluga i materijala evidentirana</td>
												</tr>
												<tr style="height:4px;">
													<td colspan="2"></td>
												</tr>
												<tr>
													<td><input type="checkbox" name="potvrda_unosa_otpusnog_pisma"  onchange="otkljucaj_zakljucenje()"></td>
													<td>prijemno/otpusno pismo uneseno ili nije potrebno</td>
												</tr>
												<tr style="height:4px;">
													<td colspan="2"></td>
												</tr>
												<tr>
													<td colspan="2">
														Zaključenje: &nbsp; 
														<select name="zakljuci_epizodu" class="inputbox inp_select" disabled="true" onchange="if(this.value=='1'){if(document.form_epizoda.datum_do.value==''){document.form_epizoda.datum_do.value='<cfoutput>#DateFormat(now(),'dd.mm.yyyy')#</cfoutput>';}}">
															<option value="0" selected="true">NE</option>
															<option value="1">DA (promjene nad epizodom više neće biti moguće)</option>
														</select>
													</td>
												</tr>
											</table>
										</td>
									</tr>
								</cfif>
							</table>
						</form>
						</cfoutput>
					</cfprocessingdirective>
				</cfsavecontent>
				
				<cfcatch type="any">
					<cfset odgovor.greska = 1>
					<cfset odgovor.poruka = odgovor.poruka & cfcatch.Message & ". " & cfcatch.detail>
				</cfcatch>
			</cftry>
			
			<cfreturn odgovor>
		</cffunction>




	<cffunction name="lista_epizoda">
		<cfargument name="id_pacijenta" type="numeric">
		<cfargument name="proknjizeno" type="numeric" default="2" hint="proknjiženo 0 = ne, 1 = da, 2 = sve">

		<cfquery name="lista_epizoda" datasource="#SESSION.Baza_podataka#">
			SELECT 
				epizoda.id,
				epizoda.broj_epizode,
				epizoda.datum_od,
				epizoda.datum_do,
				epizoda.proknjizeno,
				epizoda.epizoda_vrsta_id,
				epizoda.maticni_broj,
				epizoda.napomena,
				epizoda.broj_bolnickih_dana,
				epizoda.rbo,
				epizoda.djelatnost,
				epizoda.kat_osiguranja,
				epizoda.opstina,
				epizoda.osiguran_od,
				epizoda.osiguran_do,
				epizoda.status_osiguranja,
				epizoda.skladiste_grupa,
				epizoda.skladiste,
				epizoda_vrsta.naziv AS naziv_vrste,
				skladiste_grupa.naziv AS skladiste_grupa_naziv,
				skladiste.naziv AS skladiste_naziv,
				k1.ime AS ime_korisnika_otvorio,
				k1.prezime AS prezime_korisnika_otvorio,			
				k2.ime AS ime_korisnika_zatvorio,
				k2.prezime AS prezime_korisnika_zatvorio
			FROM epizoda
			LEFT JOIN epizoda_vrsta ON epizoda_vrsta.id = epizoda.epizoda_vrsta_id 
			LEFT JOIN skladiste_grupa ON skladiste_grupa.ID = epizoda.skladiste_grupa 
			LEFT JOIN skladiste ON skladiste.ID = epizoda.skladiste 
			LEFT JOIN conf_korisnici AS k1 ON k1.id = epizoda.id_korisnika_otvorio
			LEFT JOIN conf_korisnici AS k2 ON k2.id = epizoda.id_korisnika_zatvorio
			WHERE id_pacijenta = #Val(arguments.id_pacijenta)#
			<cfif (Val(arguments.proknjizeno) not equal 2)>
				AND epizoda.proknjizeno = #Val(arguments.proknjizeno)#
			</cfif>
			ORDER BY epizoda.datum_od DESC, epizoda.id DESC
		</cfquery>
		<cfreturn lista_epizoda>
	</cffunction>










	<cffunction name="lista_vrsta_epizoda">
		<cfargument name="id" type="string" required="no" default="">

		<cfquery name="lista_vrsta_epizoda" datasource="#SESSION.Baza_podataka#">
			SELECT 
				epizoda_vrsta.id, 
				epizoda_vrsta.naziv 
			FROM epizoda_vrsta 
			WHERE 0 = 0
			<cfif (#Val(arguments.id)# not equal 0)>
				AND epizoda_vrsta.id = #Val(arguments.id)# 
			</cfif>
			ORDER BY epizoda_vrsta.naziv ASC
		</cfquery>

		<cfreturn lista_vrsta_epizoda>
	</cffunction>










		<cffunction name="epizoda_akcija" returntype="struct" access="remote">			
			<cfargument name="id_epizode" type="numeric" default="0" required="true">
			<cfargument name="id_pacijenta" type="numeric" default="0" reqired="true">
			<cfargument name="id_korisnika" type="numeric" default="0" reqired="true">
			<cfargument name="broj_epizode" type="string" required="false" default="">
			<cfargument name="maticni_broj" type="string" required="false" default="">
			<cfargument name="datum_od" type="string" required="false" default="">
			<cfargument name="datum_do" type="string" required="false" default="">
			<cfargument name="epizoda_vrsta_id" type="numeric" required="false" default="">
			<cfargument name="napomena" type="string" required="false" default="">
			<cfargument name="fond_cache_id" type="numeric" required="false" default="0">
			<cfargument name="skladiste_grupa" type="numeric" required="false" default="0">
			<cfargument name="skladiste" type="numeric" required="false"  default="0">
			<cfargument name="proknjizeno" type="numeric" required="false" default="">
			<cfargument name="promjena_epizode" type="numeric" required="false" default="0">
			<cfargument name="id_uputnice" type="string" reqired="true" default="">
			<cfargument name="tip_uputnice" type="string" reqired="true" default="">
			<cfargument name="uputna_dijagnoza" type="string" required="false" default="">
			<cfargument name="vid_osiguranja" type="numeric" reqired="true" default="0">
			<cfargument name="vrsta_prijema" type="numeric" reqired="false" default="0">
			<cfargument name="ustanova_sifra" type="string" required="false" default="">
			<cfargument name="ljekar_sifra" type="string" required="false" default="">
			<cfset var poruka ="">

			<cfset arguments.id_epizode = Val(arguments.id_epizode)>

			<!--- id_korisnika --->
			<cfset arguments.id_korisnika = Val(arguments.id_korisnika)>
			<cfif (arguments.id_korisnika eq 0)>
				<cfif IsDefined("SESSION.id_korisnika")>
					<cfset arguments.id_korisnika = Val(SESSION.id_korisnika)>
				</cfif>
			</cfif>

			<!--- fond_cache_id --->
			<cfset arguments.fond_cache_id = Val(arguments.fond_cache_id)>
			<cfif (arguments.fond_cache_id eq 0)>
				<cfquery name="trazi_fond_cache" datasource="#SESSION.baza_podataka#">
					SELECT 
						fond_cache.id 
					FROM fond_cache 
					WHERE fond_cache.id_pacijenta = #Val(arguments.id_pacijenta)# 
					ORDER BY fond_cache.datum_provjere 
					DESC LIMIT 1
				</cfquery>
				<cfif IsDefined("trazi_fond_cache.id[1]")>
					<cfset arguments.fond_cache_id = Val(trazi_fond_cache.id[1])>
				</cfif>
			</cfif>
			
			<!--- skladiste grupa --->
			<cfif (Val(arguments.skladiste_grupa) eq 0)>
				<cfset arguments.skladiste_grupa = Val(SESSION.organizacija)>
				<cfset arguments.skladiste = Val(SESSION.organizacija_odjel)>
			</cfif>
			
			<cfif (Val(arguments.id_epizode) eq 0)>
				<cfquery name="provjera_epizode" datasource="#SESSION.baza_podataka#">
					SELECT 
						epizoda.id 
					FROM epizoda 
					WHERE epizoda.id_pacijenta = #Val(arguments.id_pacijenta)# 
					AND epizoda.epizoda_vrsta_id = #Val(arguments.epizoda_vrsta_id)# 
					AND epizoda.skladiste_grupa = #Val(arguments.skladiste_grupa)# 
					AND epizoda.skladiste = #Val(arguments.skladiste)# 
					AND epizoda.proknjizeno = 0 
					AND epizoda.skladiste_grupa <> 1202 
					ORDER BY epizoda.id DESC 
				</cfquery>
				<cfif (provjera_epizode.recordCount GTE 1)>
					<cfset arguments.id_epizode = Val(provjera_epizode.id[1])>
				</cfif>
			</cfif>

			<cfinvoke component="main" method="epizoda_detalji" returnvariable="stara_epizoda">
				<cfinvokeargument name="id_epizode" value="#Val(arguments.id_epizode)#">
			</cfinvoke>


			<!--- ako nema stare epizode, kreira novu --->
			<cfif (stara_epizoda.recordCount eq 0)>
				<cfif IsDate(arguments.datum_od)>
				<cfelse>
					<cfset arguments.datum_od = DateFormat(now(),"yyyy-mm-dd")>
				</cfif>
				
				<cfif (Val(arguments.skladiste_grupa) eq 1182) AND (arguments.tip_uputnice eq "")>
					<cfset poruka = poruka & "Niste izabrali tip uputnice. ">
				<cfelse>
					<cfquery name="unos_epizode" datasource="#SESSION.baza_podataka#" result="unos_epizode_result">
						INSERT INTO epizoda(
							id_pacijenta,
							broj_epizode,
							maticni_broj,
							datum_od,
							<cfif IsDate(arguments.datum_do)>
								datum_do,
							</cfif>
							proknjizeno,
							epizoda_vrsta_id,
							napomena,
							id_korisnika_otvorio,
							fond_cache_id, 
							id_uputnice,
							tip_uputnice,
							vid_osiguranja,
							uputna_dijagnoza,
							ustanova_sifra,
							ljekar_sifra,
							vrsta_prijema,
							skladiste_grupa, 
							skladiste, 
							skladiste_grupa_kreirao, 
							skladiste_kreirao
						)
						VALUES (
							#Val(arguments.id_pacijenta)#,
							<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#arguments.broj_epizode#">,
							<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#arguments.maticni_broj#">,
							<cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.datum_od#">,
							<cfif IsDate(arguments.datum_do)>
								<cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.datum_do#">,
							</cfif>
							0,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.epizoda_vrsta_id#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.napomena#">,
							#Val(arguments.id_korisnika)#, 
							#Val(arguments.fond_cache_id)#, 
							'#arguments.id_uputnice#',
							'#arguments.tip_uputnice#',
							#Val(arguments.vid_osiguranja)#, 
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.uputna_dijagnoza#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ustanova_sifra#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ljekar_sifra#">,
							#Val(arguments.vrsta_prijema)#, 
							#Val(arguments.skladiste_grupa)#, 
							#Val(arguments.skladiste)#,
							#Val(arguments.skladiste_grupa)#,
							#Val(arguments.skladiste)# 
						)
					</cfquery>
					<cfset arguments.id_epizode = Val(unos_epizode_result.GENERATED_KEY)>
					<cfset upis = Upisi_log("epizoda unos", "", unos_epizode_result.sql)>
	
					<!--- postavlja broj epizode --->
					<cfif (arguments.broj_epizode eq "")>
						<cfquery name="aktivna_epizoda" datasource="#SESSION.baza_podataka#">
							UPDATE epizoda 
							SET 
								broj_epizode = '#Val(arguments.id_epizode)#/#Right(year(now()),2)#'
							WHERE epizoda.id = #Val(arguments.id_epizode)#
						</cfquery>
					</cfif>
	
					<!--- odmah postavlja kao aktivnu --->
					<cfquery name="aktivna_epizoda" datasource="#SESSION.baza_podataka#">
						UPDATE pacijenti 
						SET 
							id_epizode = #Val(arguments.id_epizode)#
						WHERE pacijenti.id = #Val(id_pacijenta)#
					</cfquery>
				</cfif>

			<!--- mijenja podatke o epizodi ako nije proknjižena --->
			<cfelse>
				<cfif (Val(arguments.skladiste_grupa) eq 1182) AND (arguments.tip_uputnice eq "")>
					<cfset poruka = poruka & "Niste izabrali tip uputnice. ">
				<cfelse>
					<cfif (Val(stara_epizoda.proknjizeno[1]) eq 0)>
						<cfquery name="update_epizode" datasource="#SESSION.baza_podataka#" result="update_epizode_result">
							UPDATE epizoda 
							SET
								<cfif (arguments.broj_epizode not equal "")>
									broj_epizode = <cfqueryparam cfsqltype="CF_SQL_CHAR" value="#arguments.broj_epizode#">,
								</cfif>
								<cfif (arguments.maticni_broj not equal "")>
									maticni_broj = <cfqueryparam cfsqltype="CF_SQL_CHAR" value="#arguments.maticni_broj#">,
								</cfif>
								<cfif IsDate(arguments.datum_od)>
									datum_od = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.datum_od#">,
								</cfif>
								<cfif IsDate(arguments.datum_do) OR !Len(arguments.datum_do)>
									datum_do = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.datum_do#" null="#!Len(arguments.datum_do)#">,
								</cfif>
								<cfif !Len(arguments.datum_do)>
									id_korisnika_zatvorio = null,
								</cfif>
								<cfif IsNumeric(arguments.epizoda_vrsta_id)>
									epizoda_vrsta_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Val(arguments.epizoda_vrsta_id)#">,
								</cfif>
								<cfif (arguments.napomena not equal "")>
									napomena = 	<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#arguments.napomena#">,
								</cfif>
								skladiste_grupa = #Val(arguments.skladiste_grupa)#, 
								skladiste = #Val(arguments.skladiste)#,
								fond_cache_id = #Val(arguments.fond_cache_id)#, 
								id_uputnice = '#arguments.id_uputnice#',
								tip_uputnice = '#arguments.tip_uputnice#',
								vid_osiguranja = #Val(arguments.vid_osiguranja)#, 
								uputna_dijagnoza = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.uputna_dijagnoza#">,
								ustanova_sifra = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ustanova_sifra#">,
								ljekar_sifra = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ljekar_sifra#">,
								vrsta_prijema = #Val(arguments.vrsta_prijema)#
							WHERE epizoda.id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Val(arguments.id_epizode)#">	
						</cfquery>	
						<cfset upis = Upisi_log("epizoda izmjena", "", update_epizode_result.sql)>
						
						<!--- mijenja aktivnu epizodu --->
						<cfif (promjena_epizode eq 1)>
							<cfquery name="aktivna_epizoda" datasource="#SESSION.baza_podataka#">
								UPDATE pacijenti 
								SET 
									id_epizode = #Val(arguments.id_epizode)#
								WHERE pacijenti.id = #Val(arguments.id_pacijenta)#
							</cfquery>
						</cfif>
	
						<!--- zaključuje epizodu --->
						<cfif (Val(arguments.proknjizeno) eq 1)>
	
							<!--- traži matični list za kliničku epizodu --->
							<cfset greska_zakljucenja_epizode = 0>
							<cfif (epizoda_vrsta_id eq 2)>
								<cfquery name="trazi_maticni_list" datasource="#SESSION.Baza_podataka#">
									SELECT id
									FROM dokumenti 
									WHERE dokumenti.id_forme = 252
									AND dokumenti.id_pacijenta = #id_pacijenta#
									AND dokumenti.id_epizode = #id_epizode#
								</cfquery>
						
								<cfif (
									(trazi_maticni_list.recordCount eq 0) AND 
									(ListFindNoCase(SESSION.grupa_korisnika, 2) eq 0) AND 
									(ListFindNoCase(SESSION.grupa_korisnika, 1) eq 0)
								)>
									<cfset greska_zakljucenja_epizode = 1>
									<cfset poruka = poruka & "Kliničku epizodu nije moguće zatvoriti bez matičnog lista. ">
								</cfif>
							</cfif>
	
							<cfif (
								IsDate(arguments.datum_od) AND 
								IsDate(arguments.datum_do) AND 
								(DateCompare(arguments.datum_od,arguments.datum_do,"d") LTE 0) AND
								(greska_zakljucenja_epizode eq 0)
							)>
								<cftransaction>
								<cfquery name="zakljuci_epizodu" datasource="#SESSION.baza_podataka#" result="zakljuci_epizodu_result">
									UPDATE epizoda 
									SET 
										proknjizeno = 1,
										id_korisnika_zatvorio = #Val(arguments.id_korisnika)#
									WHERE id = #Val(arguments.id_epizode)#	
								</cfquery>
								
								<cfquery name="aktivna_epizoda_brisanje" datasource="#SESSION.baza_podataka#">
									UPDATE pacijenti 
									SET 
										id_epizode = 0
									WHERE pacijenti.id_epizode = #Val(arguments.id_epizode)#	
								</cfquery>
								</cftransaction>
								
								<cfset upis = Upisi_log("epizoda zakljucavanje", "", zakljuci_epizodu_result.sql)>
								
								<cfquery name="aktivne_epizode_pacijenta" datasource="#SESSION.baza_podataka#">
									SELECT 
										epizoda.id 
									FROM epizoda 
									WHERE epizoda.id_pacijenta = #Val(arguments.id_pacijenta)# 
									AND epizoda.proknjizeno = 0 
									ORDER BY epizoda.id DESC 
								</cfquery>
								<cfif (aktivne_epizode_pacijenta.recordCount GTE 1)>
									<cfquery name="aktivna_epizoda_nova" datasource="#SESSION.baza_podataka#">
										UPDATE pacijenti 
										SET 
											id_epizode = #Val(aktivne_epizode_pacijenta.id[1])#
										WHERE pacijenti.id = #Val(arguments.id_pacijenta)#	
									</cfquery>
								</cfif>
							<cfelse>	
								<cfset poruka = poruka & "Datumi nisu ispravni, ili je datum početka veći od datuma zaključenja. ">
							</cfif>
						</cfif>
	
					<cfelse>
						<cfset poruke = poruka & "Epizoda je proknjižena (zaključena) i nije moguće mijenjati podatke. ">
					</cfif>
				</cfif>
			</cfif>
			
			<!--- vraća detalje epizode --->
			<cfset odgovor.epizoda_detalji = epizoda_detalji(id_epizode)>
			<cfset odgovor.poruka = poruka>

			<cfreturn odgovor>
		</cffunction>





		<cffunction name="epizoda_zatvaranje_auto" access="remote" returntype="struct">
			<cfargument name="epizoda_vrsta" type="numeric" default="1">
			<cfset var odgovor = StructNew()>
			<cfset odgovor.greska = 0>
			<cfset odgovor.poruka = "">
			<cftry>
				<cfquery name="lista_otvorenih" datasource="#SESSION.Baza_podataka#">
					SELECT 
						pacijenti.id AS id_pacijenta,
						pacijenti.id_epizode 
					FROM pacijenti 
					LEFT JOIN epizoda ON epizoda.id = pacijenti.id_epizode 
					WHERE pacijenti.id_epizode IS NOT NULL 
					AND pacijenti.id_epizode > 0 
					AND epizoda.epizoda_vrsta_id = #Val(arguments.epizoda_vrsta)#
					AND epizoda.proknjizeno = 0 
					AND (
						(
							(epizoda.datum_od < '#DateFormat(DateAdd("d", -3, now()), "yyyy-mm-dd")#') 
							AND 
							(epizoda.skladiste_grupa NOT IN (1201,1205))
						)
						OR 
						(
							(epizoda.datum_od < '#DateFormat(DateAdd("d", -7, now()), "yyyy-mm-dd")#') 
							AND 
							(epizoda.skladiste_grupa IN (1201,1205))
						)
					)
					ORDER BY epizoda.datum_od ASC
				</cfquery>
				
				<cfloop query="lista_otvorenih">
					<cftry>
						<cftransaction>
							<cfquery name="update_epizode" datasource="#SESSION.Baza_podataka#">
								UPDATE epizoda 
								SET 
									proknjizeno = 1,
									id_korisnika_zatvorio = 8, 
									datum_do = IFNULL(
										(
											SELECT 
												Date(dokumenti.datum_kreiranja) 
											FROM dokumenti 
											WHERE dokumenti.id_epizode = epizoda.id 
											ORDER BY dokumenti.datum_kreiranja DESC 
											LIMIT 1
										),
										datum_od
									)
								WHERE epizoda.id = #Val(lista_otvorenih.id_epizode)#
							</cfquery>
							
							<cfquery name="update_pacijenta" datasource="#SESSION.baza_podataka#">
								UPDATE pacijenti 
								SET 
									id_epizode = 0
								WHERE pacijenti.id = #Val(lista_otvorenih.id_pacijenta)#
							</cfquery>
						</cftransaction>
						<cfcatch type="any">
							<cfset odgovor.greska = 1>
							<cfset odgovor.poruka = odgovor.poruka & cfcatch.Message & ". " & cfcatch.detail>
						</cfcatch>
					</cftry>
				</cfloop>
			
				<cfcatch type="any">
					<cfset odgovor.greska = 1>
					<cfset odgovor.poruka = odgovor.poruka & cfcatch.Message & ". " & cfcatch.detail>
				</cfcatch>
			</cftry>
			<cfreturn odgovor>
		</cffunction>





		<cffunction name="protokol_detalji" returntype="string">
			<cfargument name="id_pacijenta" type="numeric" default="0">
			<cfargument name="id_epizode" type="numeric" default="0">
			<cfset var odgovor = arguments.id_epizode>
			<cfif (
				(Val(arguments.id_pacijenta) not equal 0) AND 
				(Val(arguments.id_epizode) not equal 0)
			)>
				<cfquery name="trazi_epizodu" datasource="#SESSION.baza_podataka#">
					SELECT 
						epizoda.broj_epizode, 
						epizoda.epizoda_vrsta_id 
					FROM epizoda 
					WHERE epizoda.id = #Val(arguments.id_epizode)#
				</cfquery>
				<cfif (Val(trazi_epizodu.epizoda_vrsta_id[1]) GTE 2)>
					<cfquery name="trazi_protokol" datasource="#SESSION.baza_podataka#">
						SELECT 
							dokumenti_detalji_char.vrijednost 
						FROM dokumenti_detalji_char 
						LEFT JOIN dokumenti ON dokumenti.id = dokumenti_detalji_char.id_dokumenta 
						WHERE dokumenti_detalji_char.id_pacijenta = #Val(arguments.id_pacijenta)# 
						AND dokumenti_detalji_char.id_forme = 173 
						AND dokumenti_detalji_char.id_modula = 1160 
						AND dokumenti_detalji_char.aktivno = 1
						AND dokumenti.id_epizode = #Val(arguments.id_epizode)# 
						ORDER BY dokumenti_detalji_char.id DESC 
						LIMIT 1
					</cfquery>
					<cfif (trazi_protokol.recordCount eq 1)>
						<cfif (trazi_protokol.vrijednost[1] not equal "")>
							<cfset odgovor = trazi_protokol.vrijednost[1]>
						</cfif>
					</cfif>
				<cfelse>
					<cfset odgovor = trazi_epizodu.broj_epizode[1]>
				</cfif>
			</cfif>
			<cfreturn odgovor>
		</cffunction>





		<cffunction name="lista_formi">
			<cfquery name="lista_formi" datasource="#SESSION.Baza_podataka#">
				SELECT 
					forma.id,
					forma.id_grupe,
					forma.naziv, 
					forma_grupe.id AS id_grupe,
					forma_grupe.naziv AS naziv_grupe 
				FROM forma 
				LEFT JOIN forma_grupe ON forma_grupe.id = forma.id_grupe 
				ORDER BY forma_grupe.naziv, forma.naziv
			</cfquery>
			<cfreturn lista_formi>
		</cffunction>





		<cffunction name="lista_modula_forme">
				<cfargument name="id_forme" type="numeric" default="0">
	
				<cfquery name="lista_modula_forme" datasource="#SESSION.Baza_podataka#">
					SELECT
						forma_moduli.id,
						forma_moduli.moduli_vrste_id,
						forma_moduli.id_forme,
						forma_moduli.naziv_modula,
						forma_moduli.required,
						forma_moduli.default_vrijednost,
						forma_moduli.broj_decimala,
						forma_moduli.class,
						forma_moduli.style,
						forma_moduli.disabled,
						forma_moduli.iteracija,
						forma_moduli.napredni_editor,
						forma_moduli.readonly,
						forma_moduli.onkeyup,
						forma_moduli.onclick,
						forma_moduli.onblur,
						forma_moduli.onfocus,
						forma_moduli.onchange,
						forma_moduli.triger,
						forma_moduli.ref_1,
						forma_moduli.ref_2,
						forma_moduli.ref_3,
						forma_moduli.ref_4,
						forma_moduli.tabindex,
						forma_moduli.reg_ekspresija,
						forma_moduli.stampaj_prazan,
						moduli_vrste.tabela_vrijednost,
						moduli_vrste.objekat_tip
					FROM forma_moduli
					LEFT JOIN moduli_vrste ON moduli_vrste.id = forma_moduli.moduli_vrste_id
					<cfif IsNumeric(id_forme)>
						WHERE forma_moduli.id_forme = #id_forme#
					</cfif>
					ORDER BY moduli_vrste.tabela_vrijednost ASC 
				</cfquery>
			<cfreturn lista_modula_forme>
		</cffunction>

		<cffunction name="lista_grupa_formi">
				<cfquery name="lista_grupa_formi" datasource="#SESSION.Baza_podataka#">
					SELECT
					forma_grupe.id,
					forma_grupe.parent_id,
					forma_grupe.naziv AS naziv_grupe
					FROM forma_grupe
					ORDER BY sort ASC
				</cfquery>
			<cfreturn lista_grupa_formi>
		</cffunction>

		<cffunction name="lista_tipova_podataka">
			<cfquery name="lista_tipova_podataka" datasource="#SESSION.Baza_podataka#">
				SELECT id, naziv, binding_1, binding_2
				FROM tip_podatka
			</cfquery>
			<cfreturn lista_tipova_podataka>
		</cffunction>
		
		<cffunction name="tip_podataka_detalji">
			<cfargument name="tip_podatka_id" type="numeric" default="0">
			<cfargument name="id_pacijenta" type="numeric" default="0">
			<cfargument name="id_forme" type="numeric" default="0">
			<cfargument name="id_epizode" type="numeric" default="0">
			<cfargument name="datum_od" type="string" default="">
			<cfargument name="datum_do" type="string" default="">
			
			<cfset var query_string= "">
			<cfset var tmp_tabela_vrijednost = "">			


			<cfquery name="lista_modula_za_tip_podataka" datasource="#SESSION.baza_podataka#">
				SELECT 
				tip_podatka_modul_cross.id, 
				tip_podatka_modul_cross.tip_podatka_id, 
				tip_podatka_modul_cross.modul_id AS id_modula,
				forma_moduli.naziv_modula,
				forma_moduli.moduli_vrste_id,
				forma_moduli.id_forme AS id_forme,
				moduli_vrste.tabela_vrijednost
				FROM tip_podatka_modul_cross
				LEFT JOIN forma_moduli on forma_moduli.id = tip_podatka_modul_cross.modul_id
				LEFT JOIN moduli_vrste ON moduli_vrste.id = forma_moduli.moduli_vrste_id
				WHERE tip_podatka_id = #tip_podatka_id#
				ORDER BY tabela_vrijednost
			</cfquery>

			<cfloop query="lista_modula_za_tip_podataka">
				<cfif tmp_tabela_vrijednost not equal #lista_modula_za_tip_podataka.tabela_vrijednost#>
					<cfif lista_modula_za_tip_podataka.CurrentRow GT 1>
						<cfset  query_string = query_string & ") UNION ">
					</cfif>
					<cfset query_string = query_string & "SELECT dokumenti.datum_kreiranja, dokumenti.id_epizode, #lista_modula_za_tip_podataka.tabela_vrijednost#.id_forme, dokumenti.id_pacijenta, dokumenti.id_epizode, #lista_modula_za_tip_podataka.tabela_vrijednost#.id_dokumenta, '#lista_modula_za_tip_podataka.naziv_modula#' AS naziv_modula, forma.naziv AS naziv_forme, CAST(vrijednost AS char) AS vrijednost FROM " & #lista_modula_za_tip_podataka.tabela_vrijednost# >
					<cfset query_string = query_string & " LEFT JOIN dokumenti ON dokumenti.id = #lista_modula_za_tip_podataka.tabela_vrijednost#.id_dokumenta "> 
					<cfset query_string = query_string & " LEFT JOIN forma ON forma.id = #lista_modula_za_tip_podataka.tabela_vrijednost#.id_forme "> 

					<cfset query_string = query_string & " WHERE 1=1 ">
					<cfset query_string = query_string & " AND #lista_modula_za_tip_podataka.tabela_vrijednost#.id_pacijenta = " & id_pacijenta>
					
					<cfif VAL(id_pacijenta) gt 0>
						<cfset query_string = query_string & " AND " & #lista_modula_za_tip_podataka.tabela_vrijednost# & ".id_pacijenta = " & id_pacijenta>
					</cfif>	
						
					<cfif VAL(id_forme) gt 0>
						<cfset query_string = query_string & " AND #lista_modula_za_tip_podataka.tabela_vrijednost#.id_forme = " & id_forme>
					</cfif>	
			
					<cfif VAL(id_epizode) gt 0>
						<cfset query_string = query_string & " AND dokumenti.id_epizode = " & id_epizode>
					</cfif>	
			
					<cfif Isdate(datum_od)>
						<cfset query_string = query_string & " AND dokumenti.datum_kreiranja >= '" & #DateFormat(datum_od,"yyyy-mm-dd")# & "'">
					</cfif>
					
					<cfif Isdate(datum_do)>
						<cfset query_string = query_string & " AND dokumenti.datum_kreiranja <= '" & #DateFormat(datum_do,"yyyy-mm-dd")# & "'">
					</cfif>		
					
					<cfset query_string = query_string & " AND (0=1 ">
					<cfset tmp_tabela_vrijednost = #lista_modula_za_tip_podataka.tabela_vrijednost#>
				</cfif>	
				<cfset query_string = query_string & " OR (id_modula = " & id_modula & " AND " & #lista_modula_za_tip_podataka.tabela_vrijednost# & ".id_forme=" & lista_modula_za_tip_podataka.id_forme & " ) ">
			</cfloop>
			<cfset query_string = query_string & ") ORDER BY datum_kreiranja DESC">
			
			<cfquery name="tip_podataka_detalji" datasource="#SESSION.baza_podataka#">
				#PreserveSingleQuotes(query_string)#
			</cfquery>
			<cfreturn tip_podataka_detalji>
		</cffunction>



		<cffunction name="dokument_generalije">
			<cfargument name="id_dokumenta" type="numeric" default="0">			
				<cfquery name="ucitaj_dokument" datasource="#SESSION.Baza_podataka#">
					SELECT 
						dokumenti.id, 
						dokumenti.id_forme, 
						dokumenti.id_pacijenta,
						dokumenti.id_epizode,
						dokumenti.broj_protokola,
						dokumenti.datum_kreiranja,
						dokumenti.id_korisnika,
						dokumenti.id_korisnika_ref,
						dokumenti.sazetak,
						dokumenti.skladiste_grupa,
						dokumenti.skladiste,
						dokumenti.odrediste_skladiste_grupa,
						dokumenti.odrediste_skladiste,
						dokumenti.id_vezanog_dokumenta,
						dokumenti.custom_1,
						dokumenti.custom_2, 
						dokumenti.`status`, 
						dokumenti.obrisano,
						dokumenti.obrisano_datum,
						dokumenti.obrisano_korisnik,
						dokumenti.zavrseno,
						dokumenti.zavrseno_datum,
						dokumenti.zavrseno_korisnik,
						dokumenti.preuzeto,
						dokumenti.preuzeto_datum,
						dokumenti.preuzeto_korisnik,
						dokumenti.preuzeto_opis,
						epizoda.broj_epizode,
						epizoda.epizoda_vrsta_id,
						epizoda.datum_od,
						epizoda.datum_do,
						forma.naziv AS naziv_forme, 
						skladiste_grupa.naziv AS skladiste_grupa_naziv, 
						skladiste.naziv AS skladiste_naziv, 
						CONCAT(k1.prezime, ' ', k1.ime) AS autor_dokumenta, 
						CONCAT(k2.prezime, ' ', k2.ime) AS obrisao_dokument,
						CONCAT(k3.prezime, ' ', k3.ime) AS zavrsio_dokument, 
						CONCAT(k4.prezime, ' ', k4.ime) AS predao_dokument
					FROM dokumenti
					LEFT JOIN epizoda ON epizoda.id = dokumenti.id_epizode
					LEFT JOIN forma ON forma.id = dokumenti.id_forme 
					LEFT JOIN skladiste_grupa ON skladiste_grupa.ID = dokumenti.skladiste_grupa 
					LEFT JOIN skladiste ON skladiste.ID = dokumenti.skladiste 
					LEFT JOIN conf_korisnici AS k1 ON k1.id = dokumenti.id_korisnika 
					LEFT JOIN conf_korisnici AS k2 ON k2.id = dokumenti.obrisano_korisnik
					LEFT JOIN conf_korisnici AS k3 ON k3.id = dokumenti.zavrseno_korisnik
					LEFT JOIN conf_korisnici AS k4 ON k4.id = dokumenti.preuzeto_korisnik
					WHERE dokumenti.id = #id_dokumenta#
				</cfquery>			
				<cfreturn ucitaj_dokument>
		</cffunction>


	
    
    
    
    
		<cffunction name="dokument_data">
			<cfargument name="id_pacijenta" type="numeric" default="0">
			<cfargument name="id_epizode" type="numeric" default="0">
			<cfargument name="id_forme" type="numeric" default="0">
			<cfargument name="id_dokumenta" type="numeric" default="0">
			<cfargument name="id_dokumenta_za_detalje" type="numeric" default="0">
			<cfset var odgovor = StructNew()>
						
			
			<cfset ucitaj_dokument = dokument_generalije(id_dokumenta)>
				
			
			<cfif (#ucitaj_dokument.recordCount# eq 1)>
				<cfset id_forme = #ucitaj_dokument.id_forme[1]#>
				<cfset id_epizode = #ucitaj_dokument.id_epizode[1]#>
			</cfif>
			
			<!---Trazi formu za dokument --->
			<cfquery name="ucitaj_formu" datasource="#SESSION.Baza_podataka#">
				SELECT 
					forma.id,
					forma.naziv, 
					forma.naslov, 
					forma.obrazac, 
					forma.orijentacija_papira,
					forma.forma_pristup_profil_id,
					forma.triger,
					forma.triger_no_transaction,
					forma.id_grupe,
					forma.memorandum_gornji_id,
					forma.memorandum_donji_id,
					memorandum_1.obrazac AS memorandum_gornji_obrazac,
					memorandum_2.obrazac AS memorandum_donji_obrazac
				FROM forma
				LEFT JOIN memorandum AS memorandum_1 ON forma.memorandum_gornji_id = memorandum_1.id
				LEFT JOIN memorandum AS memorandum_2 ON forma.memorandum_donji_id = memorandum_2.id
				WHERE forma.id = #Val(arguments.id_forme)#
			</cfquery>
						
			
					
			<!--- Ucitava definiciju i do sada upisan sadrzaj svih modula za dokument --->			
			
			<cfset moduli_forme = lista_modula_forme(#id_forme#)>

			

			<!---Ucitava sadrzaj (vrijednosti) modula--->
			<!--- Uslov "id_dokumenta_za_detalje" je stavljen da se mogu ucitati detlaji sa drugog dokumenta, za slucaj da se radi dupliranje nalaza--->
			
			<cfif id_dokumenta_za_detalje equal 0>
				<cfset id_dokumenta_za_detalje = id_dokumenta>
			</cfif>
			<cfquery name="dokument_detalji_sve" datasource="#SESSION.Baza_podataka#">
			SELECT 
					dokumenti_detalji_int.id,
					#id_dokumenta# AS id_dokumenta,
					dokumenti_detalji_int.id_modula,
					dokumenti_detalji_int.id_forme,
					dokumenti_detalji_int.iteracija,
					CAST(dokumenti_detalji_int.vrijednost AS char) AS vrijednost,
					dokumenti_detalji_int.id_korisnika,
					dokumenti_detalji_int.datum_promjene,
					dokumenti_detalji_int.ref_1,
					dokumenti_detalji_int.ref_2,
					dokumenti_detalji_int.ref_3,
					dokumenti_detalji_int.ref_4,
					dokumenti_detalji_int.aktivno,
					forma_moduli.naziv_modula,
					k.ime,
					k.prezime	
			FROM dokumenti_detalji_int
			LEFT JOIN forma_moduli on forma_moduli.id = id_modula
			LEFT JOIN conf_korisnici AS k ON k.id = id_korisnika
			WHERE  dokumenti_detalji_int.id_forme = #id_forme#
			AND dokumenti_detalji_int.id_dokumenta = #id_dokumenta_za_detalje#
			AND dokumenti_detalji_int.id_pacijenta = #id_pacijenta#
			
			UNION 
			
			SELECT 
					dokumenti_detalji_dec.id,
					#id_dokumenta# AS id_dokumenta,
					dokumenti_detalji_dec.id_modula,
					dokumenti_detalji_dec.id_forme,
					dokumenti_detalji_dec.iteracija,
					CAST(dokumenti_detalji_dec.vrijednost AS char) AS vrijednost,
					dokumenti_detalji_dec.id_korisnika,
					dokumenti_detalji_dec.datum_promjene,
					dokumenti_detalji_dec.ref_1,
					dokumenti_detalji_dec.ref_2,
					dokumenti_detalji_dec.ref_3,
					dokumenti_detalji_dec.ref_4,
					dokumenti_detalji_dec.aktivno,
					forma_moduli.naziv_modula,
					k.ime,
					k.prezime	
			FROM dokumenti_detalji_dec
			LEFT JOIN forma_moduli on forma_moduli.id = id_modula
			LEFT JOIN conf_korisnici AS k ON k.id = id_korisnika
			WHERE  dokumenti_detalji_dec.id_forme = #id_forme#
			AND dokumenti_detalji_dec.id_dokumenta = #id_dokumenta_za_detalje#
			AND dokumenti_detalji_dec.id_pacijenta = #id_pacijenta#
			
			UNION 
			
			SELECT 
					dokumenti_detalji_char.id,
					#id_dokumenta# AS id_dokumenta,
					dokumenti_detalji_char.id_modula,
					dokumenti_detalji_char.id_forme,
					dokumenti_detalji_char.iteracija,
					CAST(dokumenti_detalji_char.vrijednost AS char) AS vrijednost,
					dokumenti_detalji_char.id_korisnika,
					dokumenti_detalji_char.datum_promjene,
					dokumenti_detalji_char.ref_1,
					dokumenti_detalji_char.ref_2,
					dokumenti_detalji_char.ref_3,
					dokumenti_detalji_char.ref_4,
					dokumenti_detalji_char.aktivno,
					forma_moduli.naziv_modula,
					k.ime,
					k.prezime	
			FROM dokumenti_detalji_char
			LEFT JOIN forma_moduli on forma_moduli.id = id_modula
			LEFT JOIN conf_korisnici AS k ON k.id = id_korisnika
			WHERE  dokumenti_detalji_char.id_forme = #id_forme#
			AND dokumenti_detalji_char.id_dokumenta = #id_dokumenta_za_detalje#
			AND dokumenti_detalji_char.id_pacijenta = #id_pacijenta#
			
			UNION 
			
			SELECT 
					dokumenti_detalji_text.id,
					#id_dokumenta# AS id_dokumenta,
					dokumenti_detalji_text.id_modula,
					dokumenti_detalji_text.id_forme,
					dokumenti_detalji_text.iteracija,
					CAST(dokumenti_detalji_text.vrijednost AS char) AS vrijednost,
					dokumenti_detalji_text.id_korisnika,
					dokumenti_detalji_text.datum_promjene,
					dokumenti_detalji_text.ref_1,
					dokumenti_detalji_text.ref_2,
					dokumenti_detalji_text.ref_3,
					dokumenti_detalji_text.ref_4,
					dokumenti_detalji_text.aktivno,
					forma_moduli.naziv_modula,
					k.ime,
					k.prezime	
			FROM dokumenti_detalji_text
			LEFT JOIN forma_moduli on forma_moduli.id = id_modula
			LEFT JOIN conf_korisnici AS k ON k.id = id_korisnika
			WHERE  dokumenti_detalji_text.id_forme = #id_forme#
			AND dokumenti_detalji_text.id_dokumenta = #id_dokumenta_za_detalje#
			AND dokumenti_detalji_text.id_pacijenta = #id_pacijenta#

			
			UNION 
			
			SELECT 
					dokumenti_detalji_date.id,
					#id_dokumenta# AS id_dokumenta,
					dokumenti_detalji_date.id_modula,
					dokumenti_detalji_date.id_forme,
					dokumenti_detalji_date.iteracija,
					CAST(dokumenti_detalji_date.vrijednost AS char) AS vrijednost,
					dokumenti_detalji_date.id_korisnika,
					dokumenti_detalji_date.datum_promjene,
					dokumenti_detalji_date.ref_1,
					dokumenti_detalji_date.ref_2,
					dokumenti_detalji_date.ref_3,
					dokumenti_detalji_date.ref_4,
					dokumenti_detalji_date.aktivno,
					forma_moduli.naziv_modula,
					k.ime,
					k.prezime	
			FROM dokumenti_detalji_date
			LEFT JOIN forma_moduli on forma_moduli.id = id_modula
			LEFT JOIN conf_korisnici AS k ON k.id = id_korisnika
			WHERE  dokumenti_detalji_date.id_forme = #id_forme#
			AND dokumenti_detalji_date.id_dokumenta = #id_dokumenta_za_detalje#
			AND dokumenti_detalji_date.id_pacijenta = #id_pacijenta#
			</cfquery>
			
			<cfquery name="dokument_detalji" dbtype="query">
				SELECT 
						id,
						id_dokumenta,
						id_modula,
						id_forme,
						iteracija,
						vrijednost,
						id_korisnika,
						datum_promjene,
						ref_1,
						ref_2,
						ref_3,
						ref_4,
						naziv_modula,
						ime,
						prezime,
						aktivno				
				FROM dokument_detalji_sve
				WHERE aktivno = 1
			</cfquery>

 			<cfquery name="dokument_detalji_istorijat" dbtype="query">
				SELECT 
						id,
						id_dokumenta,
						id_modula,
						id_forme,
						iteracija,
						vrijednost,
						id_korisnika,
						datum_promjene,
						ref_1,
						ref_2,
						ref_3,
						ref_4,
						naziv_modula,
						ime,
						prezime,
						aktivno
				FROM dokument_detalji_sve
				WHERE aktivno = 0
			</cfquery>
			
			
			<!--- Pravi hash sume vrijednosi, za provjeru --->
			<cfset var suma_vrijednosti = createObject("java","java.lang.StringBuffer")>		
			<cfif id_dokumenta_za_detalje equal 0>
				<cfloop query = "dokument_detalji">
					<cfif dokument_data.dokument_detalji.vrijednost not equal "">
						<cfset suma_vrijednosti.append(#dokument_data.dokument_detalji.vrijednost#)>
					</cfif>
				</cfloop>
			</cfif>
			<cfset suma_vrijednosti = hash(suma_vrijednosti)>



			<cfset odgovor.id_forme = id_forme>
			<cfset odgovor.id_epizode = id_epizode>
			<cfset odgovor.id_pacijenta = id_pacijenta>
			<cfset odgovor.id_dokumenta = id_dokumenta>
			<cfset odgovor.id_dokumenta_za_detalje = id_dokumenta_za_detalje>

			<cfset odgovor.suma_vrijednosti = suma_vrijednosti>
		
			<cfset odgovor.ucitaj_dokument = ucitaj_dokument>
			<cfset odgovor.ucitaj_formu = ucitaj_formu>
			<cfset odgovor.moduli_forme = moduli_forme>
			<cfset odgovor.dokument_detalji = dokument_detalji>
			<cfset odgovor.dokument_detalji_istorijat = dokument_detalji_istorijat>


			<cfreturn odgovor>		
		</cffunction>









		<cffunction name="dokument_akcija" returntype="struct">
			<cfargument name="dokument_parametri" type="xml">
			<cfargument name="transakcija" type="numeric" default="1">
			<cfset var tmp_id_dokumenta = Val(dokument_parametri.forma[1].XmlAttributes.id_dokumenta)>
			<cfset arguments.novi_dokument = 0>
			
			<cfif (tmp_id_dokumenta eq 0)>
				<cfset arguments.novi_dokument = 1>
				<cfquery name="kreiraj_dokument" datasource="#SESSION.baza_podataka#" result="kreiraj_dokument_result">
					INSERT INTO dokumenti(sazetak) VALUES('')
				</cfquery>
				<cfset tmp_id_dokumenta = Val(kreiraj_dokument_result.GENERATED_KEY)>
			</cfif>

			<!---setuje id_dokumenta --->
			<cfset arguments.id_dokumenta = tmp_id_dokumenta>

			<cfif (arguments.transakcija eq 1)>
				<cftransaction>
					<cfinvoke component="main" method="dokument_akcija_izvrsni" argumentCollection="#arguments#" returnVariable="odgovor">
				</cftransaction>
			<cfelse>
					<cfinvoke component="main" method="dokument_akcija_izvrsni" argumentCollection="#arguments#" returnVariable="odgovor">			
			</cfif>
			
			<cfif (
				(odgovor.greska eq "") AND  
				(odgovor.triger_no_transaction not equal "")
			)>
				<!--- komituje transakciju i ucitava triger --->
				<cftransaction action="commit">
				
				<cftry>						
					<cfset tmp_render = Render(odgovor.triger_no_transaction)>
					
					<cfcatch type="any">
						<cfset odgovor.poruka = odgovor.poruka & " " & "Greška u post-obradi. " & cfcatch.Message & " " & cfcatch.detail >
					</cfcatch>	
				</cftry>
			</cfif>

			<cfreturn odgovor>
		</cffunction>








		<cffunction name="dokument_akcija_izvrsni">		
			<cfargument name="dokument_parametri" type="xml">
			<cfargument name="transakcija" type="numeric">
			<cfargument name="novi_dokument" type="numeric">

			<!---
			Ako se radi o novom dokumentu, za ID_dokumenta staviti "NEW"
			Ako se radi o kopiranju dokumenta, id_dokumenta_za_detalje treba da ima dokument koji se kopira 
			Primjer XML dokumenta:
			
			<?xml version="1.0" encoding="UTF-8"?> 
			<forma id_dokumenta="32702" id_dokumenta_za_detalje="32702" id_epizode="47478" id_forme="119" 
				id_pacijenta="8830" suma_vrijednosti_za_sazetak="D41D8CD98F00B204E9800998ECF8427E" id_vezanog_dokumenta="123" custom_1="xxx" custom_2="yyy" 
					skladiste_grupa="1" skladiste="12" id_korisnika="1" datum_kreiranja="2012-06-28"
					odrediste_skladiste_grupa="1" odrediste_skladiste="12"	
							> 
				
				<modul id_modula="227"  ref_1="" ref_2="" ref_3="" ref_4="">H401</modul>
				<modul id_modula="2723" ref_1="" ref_2="" ref_3="" ref_4="">zcdscscs</modul>
			</forma>
			
			datum kreiranja u formatu yyyy-mm-dd
			datum unutar modula u formatu dd.mm.yyyy
			--->

			<cfset var greska = "">
			<cfset var poruka = "">
			<cfset var odgovor = StructNew()>
			<cfset var id_pacijenta = dokument_parametri.forma[1].XmlAttributes.id_pacijenta>
			<cfset var id_epizode = dokument_parametri.forma[1].XmlAttributes.id_epizode>
			<cfset var broj_protokola = dokument_parametri.forma[1].XmlAttributes.broj_protokola>
			<cfset var id_forme = dokument_parametri.forma[1].XmlAttributes.id_forme>
			<cfset var id_dokumenta_za_detalje = dokument_parametri.forma[1].XmlAttributes.id_dokumenta_za_detalje>
			<cfset var suma_vrijednosti_za_sazetak = hash(dokument_parametri.forma[1].XmlAttributes.suma_vrijednosti_za_sazetak)>
			<cfset var datum_kreiranja = DatumVrijemeSQL()>	
			<cfset var skladiste_grupa = 0>
			<cfset var odrediste_skladiste_grupa = 0>
			<cfset var skladiste = 0>
			<cfset var odrediste_skladiste = 0>
			<cfset var id_korisnika = 0>
			<cfset var id_vezanog_dokumenta = 0>
			<cfset var custom_1 = "">
			<cfset var custom_2 = "">
			<cfset var ref_4 = "">
			<cfset var required_modul_postoji = 0>
			<cfset var skraceni_opis = "">
			<cfset var stara_vrj_provjera = "">

			<cfif IsDefined("dokument_parametri.forma[1].XmlAttributes.datum_kreiranja")>
				<cfif IsDate(datum_kreiranja)>											
					<cfset datum_kreiranja = DateFormat(dokument_parametri.forma[1].XmlAttributes.datum_kreiranja,"yyyy-mm-dd") & " " & TimeFormat(dokument_parametri.forma[1].XmlAttributes.datum_kreiranja,"HH:mm:ss")>
				</cfif>
			</cfif>

			<cfif IsDefined("SESSION.organizacija")>
				<cfset skladiste_grupa = Val(SESSION.organizacija)>
				<cfset odrediste_skladiste_grupa = Val(SESSION.organizacija)>
			</cfif>

			<cfif IsDefined("dokument_parametri.forma[1].XmlAttributes.skladiste_grupa")>
				<cfset skladiste_grupa = Val(dokument_parametri.forma[1].XmlAttributes.skladiste_grupa)>
				<cfset odrediste_skladiste_grupa = Val(dokument_parametri.forma[1].XmlAttributes.skladiste_grupa)>
			</cfif>

			<cfif IsDefined("dokument_parametri.forma[1].XmlAttributes.odrediste_skladiste_grupa")>
				<cfset  odrediste_skladiste_grupa = Val(dokument_parametri.forma[1].XmlAttributes.odrediste_skladiste_grupa)>
			</cfif>

			<cfif IsDefined("SESSION.organizacija_odjel")>
				<cfset skladiste = Val(SESSION.organizacija_odjel)>
				<cfset odrediste_skladiste = Val(SESSION.organizacija_odjel)>
			</cfif>

			<cfif IsDefined("dokument_parametri.forma[1].XmlAttributes.skladiste")>
				<cfset skladiste = Val(dokument_parametri.forma[1].XmlAttributes.skladiste)>
				<cfset odrediste_skladiste = Val(dokument_parametri.forma[1].XmlAttributes.skladiste)>
			</cfif>
			
			<cfif IsDefined("dokument_parametri.forma[1].XmlAttributes.odrediste_skladiste")>
				<cfset  odrediste_skladiste = Val(dokument_parametri.forma[1].XmlAttributes.odrediste_skladiste)>
			</cfif>


			<cfif IsDefined("SESSION.id_korisnika")>
				<cfset id_korisnika = Val(SESSION.id_korisnika)>
			</cfif>
			<cfif IsDefined("dokument_parametri.forma[1].XmlAttributes.id_korisnika")>
				<cfset id_korisnika = Val(dokument_parametri.forma[1].XmlAttributes.id_korisnika)>
			</cfif>


			<cfif IsDefined("dokument_parametri.forma[1].XmlAttributes.id_vezanog_dokumenta")>
				<cfset id_vezanog_dokumenta = dokument_parametri.forma[1].XmlAttributes.id_vezanog_dokumenta>
			</cfif>

			
			<cfif IsDefined("dokument_parametri.forma[1].XmlAttributes.custom_1")>
				<cfset custom_1 = dokument_parametri.forma[1].XmlAttributes.custom_1>
			</cfif>						


			<cfif IsDefined("dokument_parametri.forma[1].XmlAttributes.custom_2")>
				<cfset custom_2 = dokument_parametri.forma[1].XmlAttributes.custom_2>
			</cfif>
			
			<cfif (broj_protokola eq "")>
				<cfset broj_protokola = id_epizode>
			</cfif>


			<cfif (arguments.novi_dokument eq 1)>
				<cfquery name="update_sazetka_dokumenta"  datasource="#SESSION.Baza_podataka#">
					UPDATE dokumenti 
					SET 
						id_forme = #id_forme#,
						id_pacijenta= #id_pacijenta#,
						id_epizode = #id_epizode#,
						broj_protokola = '#broj_protokola#',
						datum_kreiranja = '#datum_kreiranja#',
						id_korisnika = #id_korisnika#,
						sazetak = '',
						skladiste_grupa = #VAL(skladiste_grupa)#,
						skladiste = #Val(skladiste)#, 
						odrediste_skladiste_grupa = #VAL(odrediste_skladiste_grupa)#, 
						odrediste_skladiste = #VAL(odrediste_skladiste)#, 
						id_vezanog_dokumenta = #VAL(id_vezanog_dokumenta)#, 
						custom_1 = '#custom_1#', 
						custom_2 = '#custom_2#'
					WHERE id = #arguments.id_dokumenta#
				 </cfquery>

				<cfif (#id_forme# eq '247' or #id_forme# eq 247)>
					<cfquery name="update_sazetka_dokumenta"  datasource="#SESSION.Baza_podataka#">
						INSERT INTO ris_uputnice 
							(
								id_dokumenta,
								id_pacijenta,
								id_epizode,
								broj_protokola,
								datum_kreiranja,
								id_korisnika
								)
						VALUES 
							(
								#arguments.id_dokumenta#,
								#id_pacijenta#,
								#id_epizode#,
								'#broj_protokola#',
								'#datum_kreiranja#',
								#id_korisnika#
							)
					</cfquery>
				</cfif>
			<cfelse>
				<cfquery name="update_sazetka_dokumenta"  datasource="#SESSION.Baza_podataka#">
					UPDATE dokumenti 
					SET 
						broj_protokola = '#broj_protokola#' 
					WHERE id = #arguments.id_dokumenta#
				 </cfquery>
			</cfif>
			

			<!--- staviti cflock sa "dokument" + ID_pacijenta oko svega, ukljucujuci i UNION QUERY --->
			<!--- greska je "" Snimanje se nece izvrsiti ako je bilo sta pogresno, te se vraca na formu za unos, prenosi vrijednosti! --->
			
			<!---
			<cfif #dokument_data.suma_vrijednosti# not equal #suma_vrijednosti_za_sazetak#>
				<cfset greska = "Drugi korisnik je u medjuvremnu napravio izmjene na dokumentu. Vratite se na karton, ponovo otvorite dokument kako bi proucili izmjene. <br/>" & #suma_vrijednosti_za_sazetak# & "-----------" & #dokument_data.suma_vrijednosti#>
			</cfif>
			--->
			
			<cfinvoke component="main" method="dokument_data" returnVariable="dokument_data">
				<cfinvokeargument name="id_pacijenta" value="#Val(id_pacijenta)#">
				<cfinvokeargument name="id_epizode" value="#Val(id_epizode)#">
				<cfinvokeargument name="id_forme" value="#Val(id_forme)#">
				<cfinvokeargument name="id_dokumenta" value="#Val(arguments.id_dokumenta)#">
				<cfinvokeargument name="id_dokumenta_za_detalje" value="0">
			</cfinvoke>


			<!--- provjerava obavezne module (required) --->
			<cfquery name="lista_required_module" dbtype="query">
				SELECT 
					id, 
					naziv_modula
				FROM dokument_data.moduli_forme
				where required = 1
				AND objekat_tip <> 5
				AND objekat_tip <> 9
			</cfquery>

			<cfloop query="lista_required_module">
				<cfset required_modul_postoji = 0>
				<cfloop index="i" from="1" to="#ArrayLen(dokument_parametri.forma.XmlChildren)#" step="1"> 
					<cfif (lista_required_module.id EQ Val(dokument_parametri.forma[1].modul[i].XmlAttributes.id_modula))>
						<cfset required_modul_postoji = 1>								
						<cfif (dokument_parametri.forma[1].modul[i].XmlText EQ "")>
							<cfset greska = greska & "Vrijednost za " & lista_required_module.naziv_modula & " mora biti unesena!<br/>">
						</cfif>
					</cfif>
				</cfloop>
				<cfif (required_modul_postoji eq 0)>
					<cfset greska = greska & "Vrijednost za " & lista_required_module.naziv_modula & " nije dostupna!<br/>">
				</cfif>					
			</cfloop>

			<cfif (greska eq "")>

				<!---<cflock name="dokument_moduli_unos" type="exclusive" timeout="120">--->

					<!--- loopuje kroz module u submitovanoj xml strukturi --->	
					<cfloop index="i" from="1" to="#ArrayLen(dokument_parametri.forma.XmlChildren)#" step="1">
							
						<cfset id_modula = Val(dokument_parametri.forma[1].modul[i].XmlAttributes.id_modula)> 
						<cfset vrijednost_modula_tmp = dokument_parametri.forma[1].modul[i].XmlText> 

						<!---
							Pronalazi tabelu vrijednosti i ostale podatke o modulu -regexpr, requierd i sl.
							PROVJERITI REG EXPR I REQUIRED
						--->
						<cfquery name="detalji_modula" dbtype="query">
							SELECT
								id,
								moduli_vrste_id,
								naziv_modula, 
								tabela_vrijednost, 
								required, 
								reg_ekspresija,
								iteracija,
								ref_1,
								ref_2,
								ref_3,
								ref_4,
								objekat_tip
							FROM dokument_data.moduli_forme
							WHERE id = #id_modula#
						</cfquery>

						<!---  provjerava da li je slika --->
						<cfif (detalji_modula.recordCount equal 0)>
							<cfset greska = greska & "Ne postoji modul sa id: " & id_modula>
						</cfif>
											
						<!--- kod za procesiranje slike --->
						<cfif detalji_modula.objekat_tip EQ "slika">
							
							<!---OVDJE POGLEDATI LOGIKU JOS JEDNOM, OVO BI SE TREBALO IZVRSITI TEK NAKON POTVRDE DA NEMA GRESKE U MODULIMA ---->
							<!--- uklanja stare slike --->
							<cfdirectory  directory="#putanja_slika#" action="list" name="lista_fajlova" filter="#id_forme#_#id_modula#_#arguments.id_dokumenta#_*">
							<cfloop query="lista_fajlova">
								<cffile action="move" variable="sadrzaj_slike" source="#putanja_slika##lista_fajlova.name#" destination="#putanja_slika#tmp/#lista_fajlova.name#" >
							</cfloop>

							<cfloop list="#vrijednost_modula_tmp#" index="vrijednost_modula" delimiters="|">
								<cfif (vrijednost_modula not equal "")>
									<cfset naziv_novi = "#id_forme#_#id_modula#_#arguments.id_dokumenta#_" & Slucajni_broj() & ".jpg">											
									<cffile  action="write" output="#vrijednost_modula#" nameconflict="makeunique" mode="777" file="#putanja_slika##naziv_novi#">
								</cfif>
							</cfloop>

						<!--- ako nije slika --->
						<cfelse>
								
							<!--- testira stare vrijednosti --->
							<cfset stara_vrj_provjera = "">

							<cfquery name="testira_staru_vrijednost" dbtype="query">
								SELECT 
									vrijednost
								FROM dokument_data.dokument_detalji
								WHERE id_modula = #id_modula# 
								AND aktivno = 1 
								ORDER BY id ASC 
							</cfquery>
							
							<cfif IsDefined('testira_staru_vrijednost.vrijednost[1]')>
								<cfset  stara_vrj_provjera = testira_staru_vrijednost.vrijednost[1]>
							</cfif>
														
							<!--- za checkhox-ove unosi u bazu; ako nema stare vrijednosti onda insertuje --->
							<cfif (
								(testira_staru_vrijednost.recordCount less than 1) AND 
								(
									(detalji_modula.objekat_tip  equal "checkbox") OR 
									(detalji_modula.objekat_tip  equal "checkbox-float")
								)
							)>
								<cfquery name="unos_modula" datasource="#SESSION.baza_podataka#">
									INSERT INTO #detalji_modula.tabela_vrijednost[1]#(id_dokumenta, id_pacijenta, id_modula,id_forme,iteracija,vrijednost,id_korisnika,ref_1,ref_2,ref_3,ref_4, aktivno)
									VALUES(#arguments.id_dokumenta#, #id_pacijenta#, #id_modula#, #id_forme#, 1, 1, #id_korisnika#, '#detalji_modula.ref_1[1]#', '#detalji_modula.ref_2[1]#', '#detalji_modula.ref_3[1]#', '#detalji_modula.ref_4[1]#', 1)
								</cfquery>
							</cfif> 

							<!--- testira vrijednosti za iteracije i pravi varijablu tmp_iter_vrj_provjera sa starim vrijednostima  --->
							<cfif (detalji_modula.objekat_tip eq "date")>
								<cfif IsDate(stara_vrj_provjera)>
									<cfset stara_vrj_provjera = DateFormat(stara_vrj_provjera,"dd.mm.yyyy")>																
								</cfif>
							<cfelse>
								<cfset stara_vrj_provjera = testira_staru_vrijednost.vrijednost[1]>
							</cfif>
							
							<cfif (detalji_modula.iteracija eq 1)>
								<cfset stara_vrj_provjera = "">
								<cfloop query="testira_staru_vrijednost">
									<cfset stara_vrj_provjera = stara_vrj_provjera & testira_staru_vrijednost.vrijednost>																		
									<cfif testira_staru_vrijednost.currentRow not equal testira_staru_vrijednost.recordCount>
										<cfif (detalji_modula.objekat_tip eq "date")>
											<cfif IsDate(stara_vrj_provjera)>
												<cfset stara_vrj_provjera = DateFormat(stara_vrj_provjera,"dd.mm.yyyy") & "|">
											</cfif>																	
										<cfelse>
											<cfset stara_vrj_provjera = stara_vrj_provjera & "|">																
										</cfif>
									</cfif>																	
								</cfloop>
							</cfif> 

							<!--- ako je vrijednost razlicita, i nije je checkbox (koji se rjesava na kraju) ili je iteracija sa razlicitim vrijednostima --->
							<cfif (
								(ListCompact(vrijednost_modula_tmp,"|") not equal ListCompact(stara_vrj_provjera,"|")) AND
								(detalji_modula.objekat_tip not equal "checkbox") AND 
								(detalji_modula.objekat_tip not equal "checkbox-float")
							)>									

								<!--- Updatuje stare vrijednosti na aktivno 0 --->
								<cfquery name="update_modula" datasource="#SESSION.baza_podataka#">
										UPDATE #detalji_modula.tabela_vrijednost[1]#
										SET 
											aktivno = 0
										WHERE id_forme =#id_forme#
										AND id_pacijenta = #id_pacijenta#
										AND id_dokumenta = #arguments.id_dokumenta#
										AND id_modula = #id_modula#
										AND aktivno = 1															
								</cfquery>																									

								<cfset iteracija_index = 0>

								<!--- loopuje kroz vrijednost modula. ako nema iteracija, to ce biti samo jedan loop. u suprotnom, biti ce vise prolaza --->
								<cfloop list="#vrijednost_modula_tmp#" index="vrijednost_modula" delimiters="|">

									<cfset iteracija_index = iteracija_index + 1>
				
									<cfif (detalji_modula.objekat_tip eq "checkbox") OR (detalji_modula.objekat_tip eq "checkbox-float")>
										 <cfset vrijednost_modula = 1>
									</cfif>
										
									<!--- Provjerava datum --->
									<cfif (detalji_modula.tabela_vrijednost[1] eq "dokumenti_detalji_date")>
										<cfif (detalji_modula.objekat_tip eq "date")>
											<cfif (vrijednost_modula not equal "")>
												<cfset vrijednost_modula = DatumKonverzija(vrijednost_modula) & " 00:00:00">
											</cfif>
											 <cfif (IsDate(vrijednost_modula) eq False)>
												<cfset greska = greska & "Vrijednost za " & detalji_modula.naziv_modula[1] & " mora biti datum .">
											</cfif>
										<cfelseif (detalji_modula.objekat_tip eq "time")>
											 <cfif (IsDate(vrijednost_modula) eq False)>
												<cfset greska = greska & "Vrijednost za " & detalji_modula.naziv_modula[1] & " mora biti vrijeme .">
											<cfelse>
												<cfset vrijednost_modula = DateFormat(now(),"yyyy-mm-dd") & " " & vrijednost_modula & ":00">
											</cfif>
										</cfif>
									</cfif>

									<!--- Ako je decimalni ili cjelobrojni, provjerava da li je vrijednost numericka --->
									<cfif (detalji_modula.tabela_vrijednost[1] eq "dokumenti_detalji_int") OR (detalji_modula.tabela_vrijednost[1] eq "dokumenti_detalji_dec")>
										<cfif (detalji_modula.tabela_vrijednost[1] eq "dokumenti_detalji_dec")>
											<cfset vrijednost_modula = ReplaceNoCase(vrijednost_modula,",",".","all") >
										</cfif>
										
										<cfif IsNumeric(vrijednost_modula) eq false>	
											<cfset greska = greska & "Vrijednost za " & detalji_modula.naziv_modula[1] & " mora biti numericka.">
										<cfelse>
											<cfset vrijednost_modula = Val(vrijednost_modula) >
											<!--- Provjerava da li je integer za cjelobrojne --->										
											<cfif (detalji_modula.tabela_vrijednost[1] eq "dokumenti_detalji_int") AND (vrijednost_modula not equal Int(vrijednost_modula))>
												<cfset greska = greska & "Vrijednost za " & detalji_modula.naziv_modula[1] & " mora biti cjelobrojna. ">
											<cfelseif (detalji_modula.tabela_vrijednost[1] eq "dokumenti_detalji_int") AND (ABS(vrijednost_modula) greater than 2147483648)>
												<cfset greska = greska & "Vrijednost za " & detalji_modula.naziv_modula[1] & " mora biti unutar  -/+ 2^31 (2147483648).">
											</cfif>	
										</cfif>
									</cfif>

									<cfset skraceni_opis = skraceni_opis & detalji_modula.naziv_modula & ": "  & LEFT(vrijednost_modula, 10) & ", ">

									<cfset ref_1 = detalji_modula.ref_1[1]>
									<cfif IsDefined("dokument_parametri.forma[1].modul[i].XmlAttributes.ref_1")>
										<cfif (dokument_parametri.forma[1].modul[i].XmlAttributes.ref_1 not equal "")>
											<cfset ref_1 = dokument_parametri.forma[1].modul[i].XmlAttributes.ref_1>
										</cfif>
									</cfif>

									<cfset ref_2 = detalji_modula.ref_2[1]>
									<cfif IsDefined("dokument_parametri.forma[1].modul[i].XmlAttributes.ref_2")>
										<cfif (dokument_parametri.forma[1].modul[i].XmlAttributes.ref_2 not equal "")>
											<cfset ref_2 = dokument_parametri.forma[1].modul[i].XmlAttributes.ref_2>
										</cfif>
									</cfif>

									<cfset ref_3 = detalji_modula.ref_3[1]>
									<cfif IsDefined("dokument_parametri.forma[1].modul[i].XmlAttributes.ref_3")>
										<cfif (dokument_parametri.forma[1].modul[i].XmlAttributes.ref_3 not equal "")>
											<cfset ref_3 = dokument_parametri.forma[1].modul[i].XmlAttributes.ref_3>
										</cfif>
									</cfif>

									<cfset ref_4 = detalji_modula.ref_4[1]>
									<cfif IsDefined("dokument_parametri.forma[1].modul[i].XmlAttributes.ref_4")>
										<cfif (dokument_parametri.forma[1].modul[i].XmlAttributes.ref_4 not equal "")>
											<cfset ref_4 = dokument_parametri.forma[1].modul[i].XmlAttributes.ref_4>
										</cfif>
									</cfif>

									<!--- insertuje nove vrijednosti u bazu --->
									<cfif (greska eq "")>
										<cfset vrijednost_modula = ReplaceNoCase(vrijednost_modula, "##", "####", "all")>												
										<cfquery name="unos_modula" datasource="#SESSION.baza_podataka#">
											INSERT INTO #detalji_modula.tabela_vrijednost[1]#(id_dokumenta, id_pacijenta, id_modula, id_forme, iteracija, vrijednost, id_korisnika, ref_1, ref_2, ref_3, ref_4, aktivno)
											VALUES(#arguments.id_dokumenta#, #id_pacijenta#, #id_modula#, #id_forme#, #iteracija_index#, <cfqueryparam cfsqltype="cf_sql_char" value="#vrijednost_modula#">, #id_korisnika#, '#ref_1#', '#ref_2#', '#ref_3#', '#ref_4#', 1)
										</cfquery>
									</cfif>	

								</cfloop>
								
							</cfif>
					
						</cfif>

					</cfloop>

				<!---</cflock>--->

			</cfif>


			<cfif (greska eq "")>
				<cftry>

					<!--- Izvrsava skriptu u triger varijabli modula --->
					<cfloop query="dokument_data.moduli_forme">
						<cfif (dokument_data.moduli_forme.triger not equal "")>
							<cfset tmp_vrijednost_modula = "">
							<cfloop index="i" from="1" to="#ArrayLen(dokument_parametri.forma.XmlChildren)#" step="1">
								<cfset tmp_id_modula = Val(dokument_parametri.forma[1].modul[i].XmlAttributes.id_modula)> 
								<cfif (dokument_data.moduli_forme.id eq tmp_id_modula)>
									<cfset tmp_vrijednost_modula =  dokument_parametri.forma[1].modul[i].XmlText>
								</cfif>
							</cfloop>
							<cfset tmp_render = Render(dokument_data.moduli_forme.triger)>
						</cfif>
					</cfloop>

					<!--- Updatuje sazetak --->
					<cfquery name="update_sazetka_dokumenta" datasource="#SESSION.Baza_podataka#">
						UPDATE dokumenti 
						SET 
							sazetak = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#LEFT(skraceni_opis,120)#">
						WHERE id = #arguments.id_dokumenta#
					</cfquery>

					<!--- Updatuje nepostojece checkboxove na nulu --->
					<cfloop query="dokument_data.moduli_forme">
						<!--- Loopuje kroz sve module i uzima samo one gdje je checkbox i koji nije vec submitovan, kako bi ga ponistio na nulu (to je za iskljucene checkboxove) ---->
						<cfif ((dokument_data.moduli_forme.objekat_tip equal "checkbox") OR (dokument_data.moduli_forme.objekat_tip  equal "checkbox-float"))
							AND (ArrayLen(XmlSearch(dokument_parametri, "//modul[ @id_modula = #dokument_data.moduli_forme.id# ]")) eq 0)>
								<!--- ako checkbox modul ne postoji u formi a postoji u bazi updatuje se na nulu --->		
								<cfquery name="update_checkbox"  datasource="#SESSION.Baza_podataka#">
									UPDATE #dokument_data.moduli_forme.tabela_vrijednost#
									SET 
										aktivno = 0
									WHERE id_forme = #id_forme#
									AND id_dokumenta = #arguments.id_dokumenta#
									AND id_modula = #dokument_data.moduli_forme.id#
								</cfquery>
						</cfif>
					</cfloop>

					<cfif (dokument_data.ucitaj_formu.triger[1] not equal "")>
						<cfset tmp_render = Render(dokument_data.ucitaj_formu.triger[1])>
					</cfif>

					<cfcatch type="any">
						<cfset greska = "Greska u transakcijama. " & cfcatch.Message & " " & cfcatch.detail & " " & #greska#>
					</cfcatch>
				</cftry>
				
			</cfif>

	
			<!--- Ako nema greske, vrsi se update tako sto se izvrsava svaki query u protivnom slaze form varijable i vraca se na unos--->
			<cfif (greska eq "")>


			<cfelse>
				<cftransaction action="rollback">
				<cfif (arguments.novi_dokument eq 1)>
					<cflock name="novi_dokument_lock" timeout="20">
						<cfquery name="obrisi_novo_dokument_zbog greske" datasource="#SESSION.Baza_podataka#">
							DELETE FROM dokumenti WHERE id = <cfqueryparam cfsqltype="CF_SQL_NUMERIC" value="#VAL(arguments.id_dokumenta)#">
						</cfquery>
					</cflock>
				</cfif>	
				<cfset greska = "GREŠKA: " & greska>
			</cfif>
								

			<cfset odgovor.id_pacijenta = id_pacijenta>
			<cfset odgovor.id_epizode = id_epizode>
			<cfset odgovor.id_forme = id_forme>


			<cfset odgovor.novi_dokument = arguments.novi_dokument>
			<cfset odgovor.id_dokumenta = arguments.id_dokumenta>
			
			<cfset odgovor.greska = greska>
			<cfset odgovor.poruka = greska>
			<cfset odgovor.triger_no_transaction= dokument_data.ucitaj_formu.triger_no_transaction[1]>
			
			<cfreturn odgovor>
		</cffunction>





		<cffunction name="dokument_storno">		
			<cfargument name="id_dokumenta" type="numeric" required="yes" default="0">
			<cfset var greska = "">
			<cfset var odgovor = StructNew()>
			<cfset arguments.id_dokumenta = Val(arguments.id_dokumenta)>

			<cfif (arguments.id_dokumenta eq 0)>
				<cfset greska = "ID dokumenta nije definisan.">
			<cfelse>
				<cftry>
					<cfquery name="detalji_dokumenta" datasource="#SESSION.baza_podataka#">
						SELECT 
							dokumenti.* 
						FROM dokumenti 
						WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
					</cfquery>

					<cfif (
						(detalji_dokumenta.id_korisnika not equal SESSION.id_korisnika) AND 
						(ListFindNoCase(SESSION.grupa_korisnika, 1) eq 0)
					)>
						<cfset greska = "Dokument može da obriše samo autor dokumenta. ">
					<cfelseif (detalji_dokumenta.obrisano eq 1)>
						
					<cfelse>
						<cfquery name="obrisi_dokument" datasource="#SESSION.baza_podataka#">
							UPDATE dokumenti 
							SET
								obrisano = 1,
								obrisano_datum = '#DateFormat(now(),"yyyy-mm-dd")# #TimeFormat(now(),"HH:mm:ss")#', 
								obrisano_korisnik = #Val(SESSION.id_korisnika)#
                	    	WHERE dokumenti.id = #Val(arguments.id_dokumenta)# 
						</cfquery>
						<cfif (detalji_dokumenta.id_forme eq 197)>
							<cfinvoke component="kis.rpc.lab" method="lab_brisanje" returnvariable="lab_brisanje_odgovor" timeout="60">
								<cfinvokeargument name="id_dokumenta" value="#Val(arguments.id_dokumenta)#">
							</cfinvoke>
							<cfif (lab_brisanje_odgovor.greska eq 1)>
								<cfset greska = greska & " " & lab_brisanje_odgovor.poruka>
							</cfif>
						</cfif>
					</cfif>
                	<cfcatch type="any">
						<cfset greska = "Greska: " & cfcatch.Message & " " & cfcatch.detail>
					</cfcatch>
				</cftry>
			</cfif>
			<cfset odgovor.greska = greska>
			<cfset odgovor.id_dokumenta = arguments.id_dokumenta>
			<cfreturn odgovor>
		</cffunction>
		
		
		

		
		<cffunction name="dokument_status">		
			<cfargument name="id_dokumenta" type="numeric" required="yes" default="0">
			<cfargument name="status" type="string" required="yes" default="">
			<cfargument name="vrijednost" type="numeric" required="yes" default="0">
			<cfargument name="napomena" type="string" required="no" default="">
			<cfset var greska = "">
			<cfset var odgovor = StructNew()>
			<cfset arguments.id_dokumenta = Val(arguments.id_dokumenta)>

			<cfif (arguments.id_dokumenta eq 0)>
				<cfset greska = "ID dokumenta nije definisan.">
			<cfelse>
				<cftry>
					<cfquery name="detalji_dokumenta" datasource="#SESSION.baza_podataka#">
						SELECT 
							forma.triger_status,
							dokumenti.* 
						FROM dokumenti 
						LEFT JOIN forma ON forma.id = dokumenti.id_forme 
						WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
					</cfquery>

					<cfif (arguments.status eq "arhiviranje")>
						<cfif (Val(arguments.vrijednost) eq 2)>
							<cfif (Val(detalji_dokumenta.status[1]) not equal 2)>
								<cfquery name="dokument_status" datasource="#SESSION.baza_podataka#">
									UPDATE dokumenti 
									SET
										status = #Val(arguments.vrijednost)#  
									WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
								</cfquery>
							</cfif>
						<cfelseif (Val(arguments.vrijednost) eq 0)>
							<cfif (Val(detalji_dokumenta.status[1]) eq 2)>
								<cfif (Val(detalji_dokumenta.id_korisnika[1]) eq Val(SESSION.id_korisnika)) OR (SESSION.id_korisnika eq 1773)>
									<cfquery name="dokument_status" datasource="#SESSION.baza_podataka#">
										UPDATE dokumenti 
										SET
											status = #Val(arguments.vrijednost)#  
										WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
									</cfquery>
								</cfif>
							</cfif>
						</cfif>

					<cfelseif (arguments.status eq "zavrseno")>
						<cfif (Val(arguments.vrijednost) eq 1)>
							<cfif (Val(detalji_dokumenta.zavrseno[1]) eq 0)>
								<cfquery name="dokument_zavrseno" datasource="#SESSION.baza_podataka#">
									UPDATE dokumenti 
									SET
										zavrseno = #Val(arguments.vrijednost)#, 
										zavrseno_datum = '#DateFormat(now(),"yyyy-mm-dd")# #TimeFormat(now(),"HH:mm:ss")#', 
										zavrseno_korisnik = #Val(SESSION.id_korisnika)#
									WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
								</cfquery>
							</cfif>
						<cfelseif (Val(arguments.vrijednost) eq 0)>
							<cfif (
								(Val(detalji_dokumenta.zavrseno[1]) eq 1) AND 
								(
									(Val(detalji_dokumenta.id_korisnika[1]) eq Val(SESSION.id_korisnika))
									OR 
									(Val(detalji_dokumenta.zavrseno_korisnik[1]) eq Val(SESSION.id_korisnika))
								)
							)>
								<cfquery name="dokument_zavrseno" datasource="#SESSION.baza_podataka#">
									UPDATE dokumenti 
									SET
										zavrseno = #Val(arguments.vrijednost)#, 
										zavrseno_datum = NULL, 
										zavrseno_korisnik = NULL
									WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
								</cfquery>
							</cfif>
						</cfif>

					<cfelseif (arguments.status eq "preuzimanje")>
						<cfif (Val(arguments.vrijednost) eq 1)>
							<cfif (Val(detalji_dokumenta.preuzeto[1]) eq 0)>
								<cfquery name="dokument_preuzeto" datasource="#SESSION.baza_podataka#">
									UPDATE dokumenti 
									SET
										preuzeto = #Val(arguments.vrijednost)#, 
										preuzeto_datum = '#DateFormat(now(),"yyyy-mm-dd")# #TimeFormat(now(),"HH:mm:ss")#', 
										preuzeto_korisnik = #Val(SESSION.id_korisnika)#,
										preuzeto_opis = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.napomena#">
									WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
								</cfquery>
							</cfif>
						<cfelseif (Val(arguments.vrijednost) eq 0)>
							<cfif (
								(Val(detalji_dokumenta.preuzeto[1]) eq 1) AND 
								(
									(Val(detalji_dokumenta.id_korisnika[1]) eq Val(SESSION.id_korisnika))
									OR 
									(Val(detalji_dokumenta.preuzeto_korisnik[1]) eq Val(SESSION.id_korisnika))
									OR 
									(SESSION.id_korisnika eq 1773)
								)
							)>
								<cfquery name="dokument_preuzeto" datasource="#SESSION.baza_podataka#">
									UPDATE dokumenti 
									SET
										preuzeto = #Val(arguments.vrijednost)#, 
										preuzeto_datum = NULL, 
										preuzeto_korisnik = NULL,
										preuzeto_opis = NULL 
									WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
								</cfquery>
							</cfif>
						</cfif>
					</cfif>
					
					<cfif (detalji_dokumenta.triger_status[1] not equal "")>
						<cftry>						
							<cfset tmp_render = Render(detalji_dokumenta.triger_status[1])>
							
							<cfcatch type="any">
								<cfset greska = greska & cfcatch.Message & " " & cfcatch.detail>
							</cfcatch>	
						</cftry>
					</cfif>
					
                	<cfcatch type="any">
						<cfset greska = "Greska: " & cfcatch.Message & " " & cfcatch.detail>
					</cfcatch>
				</cftry>
			</cfif>
			<cfset odgovor.greska = greska>
			<cfset odgovor.id_dokumenta = arguments.id_dokumenta>
			<cfreturn odgovor>
		</cffunction>





<cffunction name="proizvod_farmakologija" access="remote" returntype="struct">
		<cfargument name="id" required="no" type="string" default="" hint="id proizvoda">
		<cfargument name="sifra" required="no" type="string" default="" hint="šifra proizvoda">
		<cfset var odgovor = StructNew()>
		<cfset var sadrzaj = "">
		<cfset var greska = "">
		<cfset arguments.id = #Val(arguments.id)#>
		<cfif (#arguments.id# eq 0)>
			<cfif (#arguments.sifra#not equal "")>
				<cfset arguments.sifra = OcistiZaQuery(arguments.sifra)>
				<cfquery name="proizvod_detalji" datasource="#SESSION.baza_podataka#">
					SELECT proizvodi.id FROM proizvodi WHERE proizvodi.sifra = '#arguments.sifra#'
				</cfquery>
				<cfif (#proizvod_detalji.recordCount# GTE 1)>
					<cfset arguments.id = #Val(proizvod_detalji.id[1])#>
				<cfelse>
					<cfset greska = greska & "Proizvod sa ovom šifrom (" & #arguments.sifra# & ") nije pronađen. ">
				</cfif>
			<cfelse>
				<cfset greska = greska & "Mora biti definisan id ili šifra proizvoda. ">
			</cfif>
		</cfif>

		<cfif (#greska# eq "")>
			<cfquery name="atc_detalji" datasource="#SESSION.baza_podataka#">
				SELECT 
					lijekovi_atc.hemijski_naziv, 
					lijekovi_atc.atc_kod, 
					lijekovi_atc.opis_lijeka,
					lijekovi_atc.trudnoca,
					lijekovi_atc.laktacija,
					lijekovi_atc.renalna_insuficijencija,
					lijekovi_atc.hepaticna_insuficijencija,
					lijekovi_atc.interakcije
				FROM lijekovi_atc
				WHERE lijekovi_atc.ID IN (SELECT id_sastojka FROM proizvodi_sastojci WHERE id_proizvoda = #arguments.id#)
			</cfquery>

			<cfif (#atc_detalji.recordCount# eq 0)>
				<cfset greska = greska & "Za dati proizvod nisu dosptupne farmakološke informacije. ">
			<cfelse>
				<cfsavecontent variable="sadrzaj">
					<cfprocessingdirective suppresswhitespace="yes">
					<?xml version="1.0" encoding="UTF-8"?>
					<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
					<html xmlns="http://www.w3.org/1999/xhtml">
					<head>
						<style type="text/css">
							body { font-family:Arial, Helvetica, sans-serif; font-size:14px; line-height:16px; }
							p { padding:0; margin:0; }
							.td_bg { background-color:#E9ECEF; font-weight:bold; color:#666; text-transform:lowercase; }	
						</style>
					</head>
					<body>
						<cfloop query="atc_detalji">
							<table border="0" cellspacing="0" cellpadding="3" style="width:100%; border:none; text-align:left; ">
								<tr>
									<td style="font-size:16px; font-weight:bold; border:1px solid #666;"><cfoutput>#atc_detalji.hemijski_naziv# &nbsp; [#atc_detalji.atc_kod#]</cfoutput></td>
								</tr>
								<tr style="height:12px;"><td></td></tr>
								<!---
								<tr>
									<td style="color:#F00;">UPOZORENJE: Navedeni podaci su u procesu provjere, te ne moraju biti ispravni!</td>
								</tr>
								--->
								<cfif (#atc_detalji.trudnoca# not equal "")>
									<tr style="height:12px;"><td></td></tr>
									<tr class="td_bg">
										<td>Upozorenja u trudnoći</td>
									</tr>
									<tr>
										<td><cfoutput>#atc_detalji.trudnoca#</cfoutput></td>
									</tr>
								</cfif>
								<cfif (#atc_detalji.laktacija# not equal "")>
									<tr><td style="height:12px;"></td></tr>
									<tr class="td_bg">
										<td>Upozorenja za laktaciju</td>
									</tr>
									<tr>
										<td><cfoutput>#atc_detalji.laktacija#</cfoutput></td>
									</tr>
								</cfif>
								<cfif (#atc_detalji.renalna_insuficijencija# not equal "")>
									<tr><td style="height:12px;"></td></tr>
									<tr class="td_bg">
										<td>Upozorenja kod renalne insuficijencije</td>
									</tr>	
									<tr>
										<td><cfoutput>#atc_detalji.renalna_insuficijencija#</cfoutput></td>
									</tr>
								</cfif>
								<cfif (#atc_detalji.hepaticna_insuficijencija# not equal "")>
									<tr><td style="height:12px;"></td></tr>
									<tr class="td_bg">
										<td>Upozorenja kod hepatičke insuficijencije</td>
									</tr>				
									<tr>
										<td><cfoutput>#atc_detalji.hepaticna_insuficijencija#</cfoutput></td>
									</tr>
								</cfif>
								<cfif (#atc_detalji.interakcije# not equal "")>
									<tr><td style="height:12px;"></td></tr>
									<tr class="td_bg">
										<td>Interakcije između lijekova: (Kategorije po Lexi-Comp-u: X- izbjegavati kombinaciju lijekova; D- razmotriti modifikaciju terapije; C- monitoring; B- bez intervencije)</td>
									</tr>		
									<tr>
										<td><cfoutput>#atc_detalji.interakcije#</cfoutput></td>
									</tr>
								</cfif>
								<tr><td style="height:12px;"></td></tr>	
								<tr class="td_bg">
									<td>Opis</td>
								</tr>		
								<tr>
									<td><cfoutput>#atc_detalji.opis_lijeka#</cfoutput></td>
								</tr>
							</table>
							<br />
						</cfloop>	
					</body>
				</html>
				</cfprocessingdirective>
			</cfsavecontent>
		</cfif>
	</cfif>

	<cfset odgovor.podaci = sadrzaj>
	<cfset odgovor.poruka = greska>
	<cfreturn odgovor>
</cffunction>





	<cffunction name="izdaj_proizvod" returntype="struct" access="remote">	
		<cfargument name="skladiste_grupa" required="yes" type="string" default="" hint="Odredjuje kliniku za koju se stanje prikazuje">
		<cfargument name="skladiste" required="yes" type="string" default="" hint="Odredjuje odjel za koji se stanje prikazuje">
		<cfargument name="id_korisnika" required="no" type="string" default="" hint="Odredjuje korisnika">
		<cfargument name="id_pacijenta" required="no" type="string" default="" hint="Odredjuje pacijenta">
		<cfargument name="id_epizode" required="no" type="string" default="" hint="Odredjuje epizodu">
		<cfargument name="id_proizvoda" required="yes" type="string" default="" hint="ID izdanog proizvoda">
		<cfargument name="kolicina" required="yes" type="numeric" default="" hint="Kolicina izdanog proizvoda">
		<cfargument name="ID_transakcije" required="no" type="string" default="" hint="ID transakcije klijenta">
		<cfargument name="omoguci_minus" required="no" type="numeric" default="0" hint="Omogucava transakciju iako proizvoda nema na stanju">
		<cfargument name="vrsta_transakcije" required="yes" type="string" default="" hint="Vrsta transakcije">
		<cfargument name="napomena" required="yes" type="string" default="" hint="napomena">

		<cfset var odgovor = StructNew()>
		<cfset odgovor.greska = 0>
		<cfset odgovor.poruka = "">

		<cfset arguments.skladiste_grupa = Val(arguments.skladiste_grupa)>
		<cfset arguments.skladiste = Val(arguments.skladiste)>
		<cfset arguments.id_korisnika = Val(arguments.id_korisnika)>
		<cfset arguments.id_pacijenta = Val(arguments.id_pacijenta)>
		<cfset arguments.id_epizode = Val(arguments.id_epizode)>
		<cfset arguments.id_proizvoda = Val(arguments.id_proizvoda)>				
		<cfset arguments.kolicina = Val(arguments.kolicina)>
		<cfset arguments.ID_transakcije = OcistiZaQuery(arguments.ID_transakcije)>
		<cfset arguments.vrsta_transakcije = OcistiZaQuery(arguments.vrsta_transakcije)>
		<cfset arguments.napomena = OcistiZaQuery(arguments.napomena)>
		
		<cfset var stanje_proizvoda = 0>

		<cfquery name="provjera_odjela" datasource="#SESSION.Baza_podataka#">
			SELECT 
				skladiste.ID 
			FROM skladiste 
			WHERE skladiste.ID_grupe = #Val(arguments.skladiste_grupa)# 
			AND skladiste.ID = #Val(arguments.skladiste)#
		</cfquery>
		<cfif (provjera_odjela.recordCount eq 0)>
			<cfset odgovor.greska = 1>
			<cfset odgovor.poruka =  odgovor.poruka & " Ne postoji data kombinacija klinika/odjel (" & Val(arguments.skladiste_grupa) & "/" & Val(arguments.skladiste) & "). ">
		</cfif>
		
		<cfif (arguments.ID_transakcije eq "")>
			<cfset odgovor.greska = 1>
			<cfset error_code_str =  error_code_str & " Nije definisan ID transakcije. ">
		</cfif>
		<cfif (Val(arguments.skladiste_grupa) eq 0)>
			<cfset odgovor.greska = 1>
			<cfset odgovor.poruka =  odgovor.poruka & " Nije definisana klinika. ">
		</cfif>
		<cfif (Val(arguments.skladiste) eq 0)>
			<cfset odgovor.greska = 1>
			<cfset odgovor.poruka =  odgovor.poruka & " Nije definisan odjel. ">
		</cfif>
		<cfif (Val(arguments.kolicina) eq 0)>
			<cfset odgovor.greska = 1>
			<cfset odgovor.poruka =  odgovor.poruka & " Nije definisana kolicina. ">
		</cfif>

		<cfif (odgovor.greska eq 0)>
			<cfquery name="provjeri_postojanje_transakcije" datasource="#SESSION.Baza_podataka#">
				SELECT 
					COUNT(*) AS broj 
				FROM detalji_podaci 
				WHERE detalji_podaci.ID_dokumenta = '#arguments.ID_transakcije#'
			</cfquery>
			<cfif (provjeri_postojanje_transakcije.broj[1] greater than 0)>		
				<cfset odgovor.greska = 1>
				<cfset odgovor.poruka =  odgovor.poruka & " Transakcija sa ovim ID-om je vec ranije izvrsena (" & arguments.ID_transakcije & "). ">		
			</cfif>
		</cfif>

		<cfif (odgovor.greska eq 0)>
			<cfquery name="detalji_proizvoda" datasource="#SESSION.Baza_podataka#" result="ListaStavki_result">
				SELECT 
					proizvodi.id AS id_proizvoda,
					proizvodi.sifra AS sifra_proizvoda,
					proizvodi.barcode,
					ROUND(proizvodi.FC,4) AS FC,
					ROUND(proizvodi.mpc,4) AS mpc,		
					ROUND(proizvodi.PDV,4) AS PDV,
					proizvodi.sifra AS iidp,						
					proizvodi.ime,
					ROUND(proizvodi.fondcijena,4) AS fondcijena,
					ROUND(proizvodi.fond_participacija,4) AS fond_participacija,
					proizvodi.fond_sifra,
					proizvodi.pakovanje,
					proizvodi.fond_participacija_procenat,
					proizvodi.konto_knjizenja,
					coalesce(proizvodi.usluga_sek_sifra,'0') AS usluga_sek_sifra,
					coalesce(proizvodi.usluga_terc_sifra,'0') AS usluga_terc_sifra, 
					proizvodi_vrsta.obracunska_grupa,
					proizvodi_stanje.stanje   
				FROM proizvodi 
				LEFT JOIN proizvodi_vrsta ON proizvodi_vrsta.id = proizvodi.id_vrste 
				LEFT JOIN proizvodi_stanje 
					ON proizvodi_stanje.id_proizvoda = proizvodi.id 
					AND proizvodi_stanje.skladiste_grupa = #Val(arguments.skladiste_grupa)# 
					AND proizvodi_stanje.skladiste = #Val(arguments.skladiste)# 
				WHERE proizvodi.id = #Val(arguments.id_proizvoda)#
			</cfquery>
			<cfif (detalji_proizvoda.recordCount not equal 1)>
				<cfset odgovor.greska = 1>
				<cfset odgovor.poruka =  odgovor.poruka & " Nepravilan ID proizvoda (" & Val(arguments.id_proizvoda) & "). ">
			<cfelse>
				<cfset odgovor.detalji_proizvoda = detalji_proizvoda>
				<cfset stanje_proizvoda = Val(detalji_proizvoda.stanje[1])>
				<cfif (Val(stanje_proizvoda) less than Val(arguments.kolicina)) AND (Val(omoguci_minus) eq 0)>
					<cfset odgovor.greska = 1>
					<cfset odgovor.poruka =  odgovor.poruka & " Nema dovoljno proizvoda za skladiste (stanje:" & stanje_proizvoda & " trazena kolicina:" & Val(arguments.kolicina) & " omoguci_minus:" & Val(omoguci_minus) & "). ">	
				</cfif>
			</cfif>
		</cfif>

		<cfif (odgovor.greska eq 0)>
			<cfset id_rekorda = Slucajni_broj()>
			<cfset datum_prodaje = DatumVrijemeSQL()>
			
			<cfquery name="Unesi_prodaje" datasource="#SESSION.Baza_podataka#" result = "Unesi_prodaje_result">
				INSERT INTO detalji_podaci(ID, vrsta, broj_racuna, ID_dokumenta, datum, sifra_proizvoda, id_proizvoda, kizlaz, stara_mpc, VPC, rab, mpc, pdv, receptbr, vid, id_pacijenta, id_epizode, dijagnoza, fond_cijena, participacija, insulin, nacin_placanja, napomena, skladiste_grupa, skladiste, konto_knjizenja, id_korisnika, obracunska_grupa)
				VALUES('#id_rekorda#', 'izlaz', 0, '#arguments.ID_transakcije#', '#datum_prodaje#', '#detalji_proizvoda.sifra_proizvoda[1]#', #Val(arguments.id_proizvoda)#, #Val(arguments.kolicina)#, #Val(detalji_proizvoda.mpc)#, #Val(detalji_proizvoda.FC)#, 0, #Val(detalji_proizvoda.mpc)#, #Val(detalji_proizvoda.PDV)#, '0', '0', #Val(arguments.id_pacijenta)#, #Val(arguments.id_epizode)#, '', #Val(detalji_proizvoda.fondcijena)#, #Val(detalji_proizvoda.fond_participacija)#, 0, 0, '#napomena#', #Val(arguments.skladiste_grupa)#, #Val(arguments.skladiste)#, '#detalji_proizvoda.konto_knjizenja[1]#', #Val(arguments.id_korisnika)#, #Val(detalji_proizvoda.obracunska_grupa[1])#)
			</cfquery>
					
			<!--- ažurira stanje --->
			<cfinvoke component="#avar_relfolder#.rpc.kalkulacije" method="proizvodi_stanje_update" returnvariable="proizvodi_stanje_update_response">
				<cfinvokeargument name="id_proizvoda" value="#Val(arguments.id_proizvoda)#">
				<cfinvokeargument name="skladiste_grupa" value="#Val(arguments.skladiste_grupa)#">
				<cfinvokeargument name="skladiste" value="#Val(arguments.skladiste)#">
			</cfinvoke>
			<cfif (proizvodi_stanje_update_response.error eq 1)>
				<cfset odgovor.greska = 1>
				<cfset odgovor.poruka = odgovor.poruka & proizvodi_stanje_update_response.message>
			</cfif>
		</cfif>

		<cfreturn odgovor>
	</cffunction>





	<cffunction name="lista_obracunskih_grupa">
		<cfquery name="lista_obrgr" datasource="#SESSION.Baza_podataka#">
			SELECT id, naziv
			FROM obracunska_grupa
		</cfquery>
		
		<cfreturn lista_obrgr>
	</cffunction>





	<cffunction name="fond_cache_detalji">
		<cfargument name="fond_cache_id" required="yes" type="string" default="0">
		<cfargument name="id_pacijenta" required="yes" type="string" default="0">
		<cfargument name="interval" required="no" type="numeric" default="0">

		<cfquery name="fond_cache_lista" datasource="#SESSION.Baza_podataka#">
			SELECT 
				fond_cache.id,
				fond_cache.id_pacijenta,
				fond_cache.id_korisnika,
				fond_cache.datum_provjere,
				fond_cache.vazi_do,
				fond_cache.forsirano,
				fond_cache.OSIG_JMB,
				fond_cache.OSIG_PREZIME,
				fond_cache.OSIG_DJEV_PREZIME,
				fond_cache.OSIG_IME,
				fond_cache.OSIG_DATUM_RODJ,
				fond_cache.OSIG_POL,
				fond_cache.OSIG_ADRESA,
				fond_cache.OSIG_OPSTINA_SIFRA,
				fond_cache.OSIG_OPSTINA,
				fond_cache.OSIG_SVOJSTVO,
				(CASE
					WHEN ((fond_cache.OSIG_NOSILAC = 'true') OR (fond_cache.OSIG_NOSILAC = '1')) THEN 1
					ELSE 0 
				END) AS OSIG_NOSILAC,
				fond_cache.OSIG_NOSILAC_JMBG,
				fond_cache.OSIG_NOSILAC_IME,
				fond_cache.OSIG_NOSILAC_PREZIME,
				fond_cache.BROJ_KNJIZICE,
				(CASE
					WHEN ((fond_cache.STATUS_OSIGURANJA = 'true') OR (fond_cache.STATUS_OSIGURANJA = '1')) THEN 1
					ELSE 0 
				END) AS STATUS_OSIGURANJA,
				fond_cache.DATUM_VAZENJA,
				fond_cache.KATEGORIJA_OSIGURANJA,
				fond_cache.NAZIV_KATEGORIJE_OSIG,
				fond_cache.OBV_NAZIV,
				fond_cache.OBV_ADRESA,
				fond_cache.OBV_OPSTINA_SIFRA,
				fond_cache.OBV_OPSTINA,
				fond_cache.OBV_JIB,
				fond_cache.OBV_OZNAKA,
				fond_cache.OBV_SIFDEL,
				fond_cache.OBV_FI_OZNAKA,
				fond_cache.OBV_PO_OZNAKA,
				fond_cache.OBV_STATUS_INO,
				fond_cache.OBV_TELEFON,
				fond_cache.OBV_NAZIV_KANCELARIJE,
				fond_cache.OBV_NAZIV_POSLOVNICE,
				fond_cache.OBV_EMAIL,
				fond_cache.OSIG_SIF_TIMA_P,
				fond_cache.SIFRA_LJEKARA,
				fond_cache.IME_LJEKARA,
				fond_cache.PREZIME_LJEKARA
			FROM fond_cache
			<cfif (Val(arguments.fond_cache_id) not equal 0)>
				WHERE fond_cache.id = #Val(arguments.fond_cache_id)# 
			<cfelseif (Val(arguments.id_pacijenta) not equal 0)>
				WHERE fond_cache.id_pacijenta = #Val(arguments.id_pacijenta)# 
			</cfif>
			<cfif arguments.interval GT 0>
				AND datum_provjere >= DATE_SUB(NOW(),INTERVAL <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.interval#"> DAY)
			</cfif>
			ORDER BY datum_provjere DESC 
			LIMIT 1
		</cfquery>
			
		<cfreturn fond_cache_lista>
	</cffunction>			





	<cffunction name="lista_grupa_skladista">
			<cfquery name="lista_grupa_skladista" datasource="#SESSION.Baza_podataka#">
				SELECT ID, naziv FROM skladiste_grupa WHERE aktivno = 1 ORDER BY ID ASC
			</cfquery>
			<cfreturn lista_grupa_skladista>
	</cffunction>		

	<cffunction name="lista_skladista">
			<cfargument name="skladiste_grupa" required="no" type="numeric" default="0" hint="Odredjuje skladiste_grupa">
			<cfquery name="lista_skladista" datasource="#SESSION.Baza_podataka#">
				SELECT 
				ID, 
				naziv 
				FROM skladiste 
				<cfif IsNumeric(skladiste_grupa)>
					WHERE ID_grupe = #Val(skladiste_grupa)#
					AND aktivno = 1
				<cfelse>
					WHERE aktivno = 1
				</cfif> 
				ORDER BY ID ASC
			</cfquery>
			<cfreturn lista_skladista>
	</cffunction>		





	<cffunction name="karton_porodicne" returntype="struct" access="remote">
		<cfargument name="id_pacijenta" type="string" required="no" default="">
		<cfargument name="jmbg" type="string" required="no" default="">
		<cfargument name="opcija" type="string" required="no" default="">
		<cfset var odgovor = StructNew()>
		<cfset var greska = 0>
		<cfset var poruka = "">
		<cfset var sadrzaj = "">
		<cfset var putanja_kartona = "">
		<cfset var sadrzaj_fajla = "">
		<cfset var izvrsi_provjeru = 0>
		<cfset var upis = "">

		<cfif (arguments.id_pacijenta eq "") AND (arguments.jmbg eq "")>
			<cfset greska = 1>
			<cfset poruka = poruka & "nije definisan parametar `id_pacijenta`. ">
		</cfif>

		<cfif (greska eq 0)>
			<cftry>
				<cfquery name="provjera_porodicna" datasource="#SESSION.baza_podataka#">
					SELECT 
						pacijenti_porodicna.id,
						pacijenti_porodicna.id_pacijenta,
						pacijenti_porodicna.datum_provjere,
						pacijenti_porodicna.jmbg,
						pacijenti_porodicna.karton,
						pacijenti_porodicna.karton_rps,
						pacijenti_porodicna.karton_lab 
					FROM pacijenti_porodicna 
					<cfif (Val(arguments.id_pacijenta) not equal 0)>
						WHERE pacijenti_porodicna.id_pacijenta = #Val(arguments.id_pacijenta)#
					<cfelse>
						WHERE pacijenti_porodicna.jmbg = '#arguments.jmbg#'
					</cfif>
					ORDER BY pacijenti_porodicna.id DESC 
					LIMIT 1
				</cfquery>
				
				<cfif (provjera_porodicna.recordCount GTE 1)>
					<cfif (DateCompare(CreateDate(Year(provjera_porodicna.datum_provjere[1]),Month(provjera_porodicna.datum_provjere[1]),Day(provjera_porodicna.datum_provjere[1])), CreateDate(Year(now()),Month(now()),day(now())), 'd') eq -1)>
						<cfset izvrsi_provjeru = 1>
					<cfelse>
						<cfset izvrsi_provjeru = 0>
					</cfif>
				<cfelse>
					<cfset izvrsi_provjeru = 1>
				</cfif>
				
				<cfif (izvrsi_provjeru eq 1)>
					<cfinvoke webservice="http://172.18.1.17/porodicna/PorodicnaKartonPacijenta.asmx?WSDL" method="GetKarton" returnvariable="putanja_kartona" timeout="15">
						<cfinvokeargument name="jmbg" value="#arguments.jmbg#">
						<cfinvokeargument name="extensia" value="htm">
						<cfinvokeargument name="pass" value="mdgs">
					</cfinvoke>
					<cfif (putanja_kartona equal "")>
						<cfset greska = 1>
						<cfset poruka = "U bazi podataka porodične medicine ne postoji pacijent sa JMBG: " & arguments.jmbg>
					</cfif>
					<cfif (greska eq 0)>
						<cfhttp url="http://172.18.1.17/#putanja_kartona#.htm" method="get" timeout="15" result="sadrzaj_osnovno">
						<cfhttp url="http://172.18.1.17/#putanja_kartona#rps.htm" method="get" timeout="15" result="sadrzaj_rps">
						<cfhttp url="http://172.18.1.17/#putanja_kartona#lab.htm" method="get" timeout="15" result="sadrzaj_lab">
						<cfif (arguments.opcija eq "rps")>
							<cfset rps1 = Html(sadrzaj_osnovno.filecontent)>
							<cfset rps2 = Html(sadrzaj_rps.filecontent)>
							<cfsavecontent variable="sadrzaj"><cfoutput><cfif IsDefined("rps2.select('table.srv_amb_rep_ter')[1]")>#rps2.select('table.srv_amb_rep_ter')[1]#</cfif> <cfif IsDefined("rps1.select('table.srv_rep_konth_ter')[1]")>#rps1.select('table.srv_rep_konth_ter')[1]#</cfif> <cfif IsDefined("rps2.select('table.srv_rep_ter')[1]")>#rps2.select('table.srv_rep_ter')[1]#</cfif></cfoutput></cfsavecontent>
						<cfelseif (arguments.opcija eq "lab")>
							<cfsavecontent variable="sadrzaj"><cfoutput>#sadrzaj_lab.filecontent#</cfoutput></cfsavecontent>
						<cfelse>
							<cfsavecontent variable="sadrzaj"><cfoutput><style type="text/css">.divSvaBolovanja, .divSveAmbt { display:none; }</style>#sadrzaj_osnovno.filecontent# #sadrzaj_rps.filecontent# #sadrzaj_lab.filecontent#</cfoutput></cfsavecontent>
						</cfif>
						<cfquery name="upis_porodicna" datasource="#SESSION.baza_podataka#">
							INSERT INTO pacijenti_porodicna (
								id_pacijenta,
								jmbg,
								datum_provjere,
								karton,
								karton_rps,
								karton_lab
							)
							VALUES (
								#Val(arguments.id_pacijenta)#,
								'#arguments.jmbg#',
								'#DateFormat(now(),"yyyy-mm-dd")# #TimeFormat(now(),"HH:mm:ss")#',
								<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#sadrzaj_osnovno.filecontent#">,
								<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#sadrzaj_rps.filecontent#">,
								<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#sadrzaj_lab.filecontent#">
							)
						</cfquery>
					</cfif>
				<cfelse>
					<cfif (arguments.opcija eq "rps")>
						<cfset rps1 = Html(provjera_porodicna.karton[1])>
						<cfset rps2 = Html(provjera_porodicna.karton_rps[1])>
						<cfsavecontent variable="sadrzaj"><cfoutput><cfif IsDefined("rps2.select('table.srv_amb_rep_ter')[1]")>#rps2.select('table.srv_amb_rep_ter')[1]#</cfif> <cfif IsDefined("rps1.select('table.srv_rep_konth_ter')[1]")>#rps1.select('table.srv_rep_konth_ter')[1]#</cfif> <cfif IsDefined("rps2.select('table.srv_rep_ter')[1]")>#rps2.select('table.srv_rep_ter')[1]#</cfif></cfoutput></cfsavecontent>
					<cfelseif (arguments.opcija eq "lab")>
						<cfsavecontent variable="sadrzaj"><cfoutput>#provjera_porodicna.karton_lab[1]#</cfoutput></cfsavecontent>
					<cfelse>
						<cfsavecontent variable="sadrzaj"><cfoutput><style type="text/css">.divSvaBolovanja, .divSveAmbt { display:none; }</style>#provjera_porodicna.karton[1]# #provjera_porodicna.karton_rps[1]# #provjera_porodicna.karton_lab[1]#</cfoutput></cfsavecontent>
					</cfif>
				</cfif>

				<cfquery name="Upis_log" datasource="#SESSION.Baza_podataka#">
					INSERT INTO log_soap(datum, vrsta, IP, korisnik, opis, sqlupit, varijable) 
					VALUES ('#DateFormat(now(),"yyyy-mm-dd")# #TimeFormat(now(),"HH:mm:ss")#', 'karton porodicne', '#ToString(CGI.REMOTE_HOST)#', <cfif IsDefined("SESSION.id_korisnika")>#Val(SESSION.id_korisnika)#<cfelse>0</cfif>, '#arguments.opcija#', '', '#arguments.jmbg#') 
				</cfquery>

				<cfcatch type="any">
					<cfset greska = 1>
					<cfset poruka = poruka & cfcatch.Message & ". " & cfcatch.detail>
				</cfcatch>
			</cftry>
		</cfif>

		<cfset odgovor.greska = greska>
		<cfset odgovor.poruka = poruka>
		<cfset odgovor.sadrzaj = sadrzaj>
		<cfreturn odgovor>
	</cffunction>





	<cffunction name="karton_porodicne_covid" returntype="struct" access="remote">
		<cfargument name="id_pacijenta" type="string" required="no" default="">
		<cfargument name="jmbg" type="string" required="no" default="">
		<cfargument name="forsiraj" type="string" required="no" default="0">
		<cfset var odgovor = StructNew()>
		<cfset var greska = 0>
		<cfset var poruka = "">
		<cfset var sadrzaj = "">
		<cfset var putanja_kartona = "">
		<cfset var sadrzaj_fajla = "">
		<cfset var izvrsi_provjeru = 0>
		<cfset var upis = "">

		<cfif (arguments.id_pacijenta eq "") AND (arguments.jmbg eq "")>
			<cfset greska = 1>
			<cfset poruka = poruka & "nije definisan parametar `id_pacijenta`. ">
		</cfif>

		<cfif (greska eq 0)>
			<cftry>
				<cfif (Val(arguments.forsiraj) eq 1)>
					<cfset izvrsi_provjeru = 1>
				<cfelse>
					<cfquery name="provjera_porodicna_covid" datasource="#SESSION.baza_podataka#">
						SELECT 
							pacijenti_covid.id,
							pacijenti_covid.id_pacijenta,
							pacijenti_covid.datum_provjere,
							pacijenti_covid.jmbg,
							pacijenti_covid.status
						FROM pacijenti_covid 
						<cfif (Val(arguments.id_pacijenta) not equal 0)>
							WHERE pacijenti_covid.id_pacijenta = #Val(arguments.id_pacijenta)#
						<cfelse>
							WHERE pacijenti_covid.jmbg = '#arguments.jmbg#'
						</cfif>
						ORDER BY pacijenti_covid.id DESC 
						LIMIT 1
					</cfquery>
					
					<cfif (provjera_porodicna_covid.recordCount GTE 1)>
						<cfif (DateCompare(CreateDate(Year(provjera_porodicna_covid.datum_provjere[1]),Month(provjera_porodicna_covid.datum_provjere[1]),Day(provjera_porodicna_covid.datum_provjere[1])), CreateDate(Year(now()),Month(now()),day(now())), 'd') eq -1)>
							<cfset izvrsi_provjeru = 1>
						<cfelse>
							<cfset izvrsi_provjeru = 0>
						</cfif>
					<cfelse>
						<cfset izvrsi_provjeru = 1>
					</cfif>
				</cfif>
				
				<cfif (izvrsi_provjeru eq 1)>
					<cfinvoke webservice="http://172.18.1.17/porodicna/PorodicnaKartonPacijenta.asmx?WSDL" method="GetCovid19Status" returnvariable="status_pacijenta" timeout="15">
						<cfinvokeargument name="jmbg" value="#arguments.jmbg#">
						<cfinvokeargument name="extensia" value="htm">
						<cfinvokeargument name="pass" value="mdgs">
					</cfinvoke>
					
					<cfif (status_pacijenta eq "")>
					
					<cfelse>
						<cfset sadrzaj = status_pacijenta>
						<cfquery name="upis_porodicna_covid" datasource="#SESSION.baza_podataka#">
							INSERT INTO pacijenti_covid (
								id_pacijenta,
								jmbg,
								datum_provjere,
								status
							)
							VALUES (
								#Val(arguments.id_pacijenta)#,
								'#arguments.jmbg#',
								'#DateFormat(now(),"yyyy-mm-dd")# #TimeFormat(now(),"HH:mm:ss")#',
								<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#sadrzaj#">
							)
						</cfquery>
					</cfif>
				<cfelse>
					<cfset sadrzaj = provjera_porodicna_covid.status[1]>
				</cfif>

				<cfcatch type="any">
					<cfset greska = 1>
					<cfset poruka = poruka & cfcatch.Message & ". " & cfcatch.detail>
				</cfcatch>
			</cftry>
		</cfif>

		<cfset odgovor.greska = greska>
		<cfset odgovor.poruka = poruka>
		<cfset odgovor.sadrzaj = sadrzaj>
		<cfreturn odgovor>
	</cffunction>





	<!--- Samo za eksternu primjenu --->
	<cffunction name="ucitaj_vrijednost_modula" returnformat="json" access="remote" returntype="struct">
		<cfargument name="id_modula" default="0">
		<cfargument name="id_forme" default="0">
		<cfargument name="id_epizode" default="0">
		<cfargument name="id_pacijenta" default="0">
		<cfargument name="obj_id" default="">
		<cfargument name="callback_name" default="">
		<cfset var odgovor = structNew()>

		<cfset odgovor.poruka = "">
		<cfset odgovor.vrijednosti_html_text = "">
		<cfset odgovor.dokumenti_html_text = "">
		<cfset odgovor.poslednja_vrijednost = "">
		<cfset odgovor.greska = 0>
		<cfset odgovor.arguments = arguments>

		<cfif (
				(Val(arguments.id_pacijenta) not equal 0) AND
				(Val(arguments.id_forme) not equal 0) AND
				(Val(arguments.id_modula) not equal 0)
				)>
			<cfquery name="trazi_dokument" datasource="#SESSION.Baza_podataka#">
							SELECT
							dokumenti.id,
							dokumenti.id_forme,
							dokumenti.id_pacijenta,
							dokumenti.datum_kreiranja
							FROM dokumenti
							WHERE dokumenti.obrisano = 0
								AND id_pacijenta = #Val(arguments.id_pacijenta)#
								AND id_forme = #Val(arguments.id_forme)#

							<cfif (Val(arguments.id_epizode) not equal 0)>
								AND id_epizode = #Val(arguments.id_epizode)#
							</cfif>

                ORDER BY datum_kreiranja DESC
			</cfquery>


				<cfquery name="trazi_formu" datasource="#SESSION.Baza_podataka#">
								SELECT
								forma.naslov
								FROM forma
								WHERE id = #Val(arguments.id_forme)#
				</cfquery>

				<cfinvoke component="main" method="lista_modula_forme" returnvariable="lista_modula_forme">
						<cfinvokeargument name="id_forme" value="#id_forme#">
				</cfinvoke>

				<cfquery name="tabela_modula" dbtype="query">
								SELECT tabela_vrijednost, naziv_modula
								FROM lista_modula_forme
								WHERE id= #arguments.id_modula#
				</cfquery>


				<cfif lista_modula_forme.RecordCount greater than 0>
					<!--- trazi poslednju vrijednost --->
						<cfquery name="trazi_vrijednost_modula" datasource="#SESSION.Baza_podataka#">
									SELECT vrijednost
									FROM #tabela_modula.tabela_vrijednost[1]#
									WHERE id_dokumenta = #VAL(trazi_dokument.id[1])#
									AND id_forme = #arguments.id_forme#
									AND id_modula = #Val(arguments.id_modula)#
									AND id_pacijenta = #arguments.id_pacijenta#
									AND aktivno = 1
						</cfquery>

						<cfif trazi_vrijednost_modula.RecordCount greater than 0>
							<cfif trazi_vrijednost_modula.vrijednost not equal "">
								<cfset odgovor.poslednja_vrijednost =  trazi_vrijednost_modula.vrijednost[1]>
							</cfif>
						</cfif>

					<!--- lista sve vrijednosti  --->

					<cfsavecontent variable="odgovor.vrijednosti_html_text">
						<cfoutput>
                            <table style="text-align:right; border:1px solid ##666; border-collapse:collapse;" cellspacing="0" cellpadding="3" bordercolor="##666666" border="1">
								<tr style="text-align:center; background-color:##ccc; font-size:11px;">
                            		<td colspan="4"><a id="xobrisi" title="...obriši" onclick="javascript: $('##izbor_vrijednosti_div_#obj_id#').remove();  kkp();"></a>
                            			#trazi_formu.naslov#
                            			<input class="button btn_add" name="dodaj" style="float:right; font-size:12px; width:22px;" value="" title="...dodaj novi dokument'" onclick="javascript: parent.ucitaj_dokument(1, #arguments.id_forme#, #arguments.id_pacijenta#,'NEW'); " type="button">
                            			<br/>
                            			[#tabela_modula.naziv_modula[1]#]
                            		</td>
								</tr>
                                <tr style="text-align:center; background-color:##ccc; font-size:11px;">
                                	<td></td>
									<td colspan="2">datum</td>
									<td>vrijednost</td>
								</tr>
								<cfloop query="trazi_dokument">
									<cfquery name="trazi_vrijednost_modula" datasource="#SESSION.Baza_podataka#">
										SELECT vrijednost
										FROM #tabela_modula.tabela_vrijednost[1]#
										WHERE id_dokumenta = #trazi_dokument.id#
										AND id_forme = #arguments.id_forme#
										AND id_modula = #arguments.id_modula#
										AND id_pacijenta = #arguments.id_pacijenta#
										AND aktivno = 1
									</cfquery>
								<tr class="klasa_redp#trazi_dokument.CURRENTROW MOD 2#" onclick="javascript:$('###arguments.obj_id#').val('#trazi_vrijednost_modula.vrijednost[1]#'); $('##izbor_vrijednosti_div_#obj_id#').remove();  #arguments.callback_name#();">
									<td><input class="button btn_search" name="document_preview" style="width:22px; height:22px;" onclick="javascript:event.stopPropagation();parent.ucitaj_dokument_hover(#trazi_dokument.id_forme#, #trazi_dokument.id_pacijenta#, #trazi_dokument.id#, event)"  onclick="this.cancelBubble=true" type="button"></td>
									<td colspan="2">#DateFormat(trazi_dokument.datum_kreiranja, "dd.mm.yyyy ")# #timeFormat(trazi_dokument.datum_kreiranja, "hh:mm:ss")#</td>
									<td>
										#trazi_vrijednost_modula.vrijednost[1]#
									</td>
								</tr>
								</cfloop>

							</table>
						</cfoutput>
					</cfsavecontent>

					<cfsavecontent variable="odgovor.dokumenti_html_text">
						<cfoutput>
                            <table style="text-align:right; border:1px solid ##666; border-collapse:collapse;" cellspacing="0" cellpadding="3" bordercolor="##666666" border="1">
                               	 <tr style="text-align:center; background-color:##ccc; font-size:11px;">
                      			 	 <td colspan="3"><a id="xobrisi" title="...obriši"  onclick="javascript: $('##izbor_vrijednosti_div_#obj_id#').remove();  kkp();"></a> #trazi_formu.naslov# 
									 	<input class="button btn_add" name="dodaj" style="float:right; font-size:12px; width:22px;" value="" title="...dodaj novi dokument'" onclick="javascript: parent.ucitaj_dokument(1, #arguments.id_forme#, #arguments.id_pacijenta#,'NEW'); " type="button">
									 </td>
								</tr>
								<tr style="text-align:center; background-color:##ccc; font-size:11px;">
										<td colspan="3">datum</td>
								</tr>
									<cfloop query="trazi_dokument">
        		                        <tr class="klasa_redp#trazi_dokument.CURRENTROW MOD 2#" onclick="javascript:$('###arguments.obj_id#').val('#trazi_dokument.id#'); $('##izbor_vrijednosti_div_#obj_id#').remove();  #arguments.callback_name#();">
											<td><input class="button btn_search" name="document_preview" style="width:22px; height:22px;" onclick="javascript:event.stopPropagation();parent.ucitaj_dokument_hover(#trazi_dokument.id_forme#, #trazi_dokument.id_pacijenta#, #trazi_dokument.id#, event)"  onclick="this.cancelBubble=true" type="button"></td>
											<td colspan="2">#DateTimeFormat(trazi_dokument.datum_kreiranja, "dd.mm.yyyy hh:mm:ss")#</td>
										</tr>
									</cfloop>

                            </table>
						</cfoutput>
					</cfsavecontent>


				</cfif>
		</cfif>
		<cfreturn odgovor>
	</cffunction>





	<cffunction name="ucitaj_sve_vrijednosti" returntype="struct" access="remote">
		<cfargument name="id_pacijenta" type="string" required="yes" default="">
		<cfset var id_epizode = 0>
		<cfset var odgovor = StructNew()>
		<cfset odgovor.greska = 0>
		<cfset odgovor.poruka = "">
		<cfset odgovor.dokumenti = "">
		<cfset odgovor.lab = "">

		<cfif (Val(arguments.id_pacijenta) eq 0)>
			<cfset odgovor.greska = 1>
			<cfset odgovor.poruka = poruka & "Nije definisan parametar `id_pacijenta`. ">
		</cfif>
		
		<cfif (odgovor.greska eq 0)>
			<cfquery name="trazi_epizodu" datasource="#SESSION.baza_podataka#">
				SELECT 
					pacijenti.id_epizode 
				FROM pacijenti 
				WHERE pacijenti.id = #Val(arguments.id_pacijenta)#
			</cfquery>
			<cfif (Val(trazi_epizodu.id_epizode[1]) not equal 0)>
				<cfset id_epizode = Val(trazi_epizodu.id_epizode[1])>
			<cfelse>
				<cfset odgovor.greska = 1>
				<cfset odgovor.poruka = poruka & "Ne postoji otvorena epizoda za datog pacijenta. ">
			</cfif>
		</cfif>

		<cfif (odgovor.greska eq 0)>
			<cftry>
				<cfquery name="lista_dokumenata" datasource="#SESSION.baza_podataka#">
					SELECT 
						p.id, 
						p.id_forme  
					FROM (
						SELECT 
							dokumenti.id, 
							dokumenti.id_forme, 
							dokumenti.datum_kreiranja  
						FROM dokumenti 
						WHERE dokumenti.id_pacijenta = #Val(arguments.id_pacijenta)# 
						AND dokumenti.id_epizode = #Val(id_epizode)# 
						AND dokumenti.id_forme IN (121,173,198,223,369,455,558,561,601,614) 
						AND dokumenti.obrisano = 0 
						ORDER BY dokumenti.id_forme ASC, dokumenti.datum_kreiranja DESC 
					) AS p 
					GROUP BY p.id_forme 
				</cfquery>
				<cfset odgovor.dokumenti = lista_dokumenata>
				
				<cfquery name="lista_modula" datasource="#SESSION.baza_podataka#">
					SELECT 
						p.id_modula,
						p.id_dokumenta,
						p.vrijednost  
					FROM (
						SELECT  
							dokumenti_detalji_char.id_dokumenta, 
							dokumenti_detalji_char.id_modula,
							dokumenti_detalji_char.vrijednost,
							dokumenti_detalji_char.datum_promjene 
						FROM dokumenti_detalji_char 
						WHERE dokumenti_detalji_char.id_forme = 198 
						AND dokumenti_detalji_char.id_modula = 2380 
						AND dokumenti_detalji_char.id_pacijenta = #Val(arguments.id_pacijenta)#
						AND dokumenti_detalji_char.aktivno = 1 
						UNION ALL 
						SELECT  
							dokumenti_detalji_int.id_dokumenta, 
							dokumenti_detalji_int.id_modula,
							dokumenti_detalji_int.vrijednost, 
							dokumenti_detalji_int.datum_promjene 
						FROM dokumenti_detalji_int 
						WHERE dokumenti_detalji_int.id_forme = 197 
						AND dokumenti_detalji_int.id_modula IN (2020,2013)
						AND dokumenti_detalji_int.id_pacijenta = #Val(arguments.id_pacijenta)#
						AND dokumenti_detalji_int.aktivno = 1 
						ORDER BY id_modula ASC, datum_promjene DESC 
					) AS p 
					GROUP BY p.id_modula  
				</cfquery>
				<cfset odgovor.lab = lista_modula>

				<cfcatch type="any">
					<cfset odgovor.greska = 1>
					<cfset odgovor.poruka = odgovor.poruka & cfcatch.Message & ". " & cfcatch.detail>
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn odgovor>
	</cffunction>





	<cffunction name="dokument_epizoda_ucitaj" returntype="struct" access="remote">
		<cfargument name="id_dokumenta" type="string" required="no" default="0">
		<cfset var odgovor = StructNew()>
		<cfset var greska = 0>
		<cfset var poruka = "">
		<cfset var sadrzaj = "">

		<cfif (Val(arguments.id_dokumenta) eq 0)>
			<cfset greska = 1>
			<cfset poruka = poruka & "ID broj dokumenta nije definisan. ">
		<cfelse>
			<cfquery name="podaci_dokumenta" datasource="#SESSION.baza_podataka#">
				SELECT 
					dokumenti.id,
					dokumenti.id_pacijenta,
					dokumenti.id_epizode,
					dokumenti.datum_kreiranja,
					forma.naziv AS naziv_forme 
				FROM dokumenti 
				LEFT JOIN forma ON forma.id = dokumenti.id_forme 
				WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
			</cfquery>
			<cfif (podaci_dokumenta.recordCount eq 0)>
				<cfset greska = 1>
				<cfset poruka = poruka & "Dokument nije pronađen. ">
			</cfif>
		</cfif>
					
		<cfif (greska eq 0)>
			<cftry>
				<cfquery name="lista_epizoda" datasource="#SESSION.baza_podataka#">
					SELECT 
						epizoda.id,
						epizoda.broj_epizode,
						epizoda.datum_od,
						epizoda.datum_do,
						epizoda.epizoda_vrsta_id,
						epizoda.skladiste_grupa,
						epizoda_vrsta.naziv AS naziv_vrste,
						skladiste_grupa.naziv AS skladiste_grupa_naziv
					FROM epizoda
					LEFT JOIN epizoda_vrsta ON epizoda_vrsta.id = epizoda.epizoda_vrsta_id 
					LEFT JOIN skladiste_grupa ON skladiste_grupa.ID = epizoda.skladiste_grupa 
					WHERE id_pacijenta = #Val(podaci_dokumenta.id_pacijenta[1])#
					ORDER BY epizoda.datum_od DESC, epizoda.id DESC
				</cfquery>
				
				<cfsavecontent variable="sadrzaj">
					<cfprocessingdirective suppresswhitespace="yes">
						<cfoutput>
						<form name="dokument_epizoda_form" method="post" onsubnit="return false">
							<input type="hidden" name="id_dokumenta" value="#Val(arguments.id_dokumenta)#" />
							
							<table border="0" cellpadding="0" cellspacing="0" class="fontbc" style="width:640px; border:none; text-align:left;">
								<tr>
									<td>
										Izaberite epizodu kojoj želite da pridružite ovaj dokument:<br />
										<span style="font-weight:bold;">#podaci_dokumenta.naziv_forme[1]#</span> od <span style="font-weight:bold;">#DateFormat(podaci_dokumenta.datum_kreiranja[1],"dd.mm.yyyy")#</span>
									</td>
								</tr>
								<tr>
									<td>
										<select class="inputbox inp_select" name="id_epizode" style="width:100%;">
											<cfoutput query="lista_epizoda">
												<option value="#lista_epizoda.id#" <cfif (Val(podaci_dokumenta.id_epizode[1]) eq Val(lista_epizoda.id))>selected="selected"</cfif>>#DateFormat(lista_epizoda.datum_od,"dd.mm.yyyy")# - #lista_epizoda.naziv_vrste# #lista_epizoda.broj_epizode#<cfif (Val(podaci_dokumenta.id_epizode[1]) eq Val(lista_epizoda.id))> (TRENUTNA)</cfif></option>
											</cfoutput>
										</select>
									</td>
								</tr>
							</table>
						</form>
						</cfoutput>
					</cfprocessingdirective>
				</cfsavecontent>

				<cfcatch type="any">
					<cfset greska = 1>
					<cfset poruka = poruka & cfcatch.Message & ". " & cfcatch.detail>
				</cfcatch>
			</cftry>
		</cfif>

		<cfset odgovor.greska = greska>
		<cfset odgovor.poruka = poruka>
		<cfset odgovor.sadrzaj = sadrzaj>
		<cfreturn odgovor>
	</cffunction>





	<cffunction name="dokument_epizoda_sacuvaj" returntype="struct" access="remote">
		<cfargument name="id_dokumenta" type="string" required="no" default="0">
		<cfargument name="id_epizode" type="string" required="no" default="0">
		<cfset var odgovor = StructNew()>
		<cfset var greska = 0>
		<cfset var poruka = "">
		<cfset var podaci_dokumenta = "">
		<cfset var podaci_epizode = "">
		<cfset var update_dokumenta = "">
		<cfset var qUpd = "">
		
		<cfif (Val(arguments.id_dokumenta) eq 0)>
			<cfset greska = 1>
			<cfset poruka = poruka & "ID broj dokumenta nije definisan. ">
		<cfelse>
			<cfquery name="podaci_dokumenta" datasource="#SESSION.baza_podataka#">
				SELECT 
					dokumenti.id,
					dokumenti.id_pacijenta,
					dokumenti.id_epizode,
					dokumenti.id_forme
				FROM dokumenti 
				WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
			</cfquery>
			<cfif (podaci_dokumenta.recordCount eq 0)>
				<cfset greska = 1>
				<cfset poruka = poruka & "Dokument nije pronađen. ">
			</cfif>
		</cfif>
		
		<cfif (Val(arguments.id_epizode) eq 0)>
			<cfset greska = 1>
			<cfset poruka = poruka & "Niste izabrali epizodu kojoj želite da pridružite dokument. ">
		<cfelse>
			<cfquery name="podaci_epizode" datasource="#SESSION.baza_podataka#">
				SELECT 
					epizoda.id,
					epizoda.id_pacijenta,
					epizoda.broj_epizode,
					epizoda.datum_od,
					epizoda.datum_do,
					epizoda.ihe_uputnica_unique_id, 
					epizoda.ihe_uputnica_tip, 
					epizoda.ihe_uputnica_id_dokumenta
				FROM epizoda 
				WHERE epizoda.id = #Val(arguments.id_epizode)#
			</cfquery>
			<cfif (podaci_epizode.recordCount eq 0)>
				<cfset greska = 1>
				<cfset poruka = poruka & "Epizoda nije pronađena. ">
			</cfif>
		</cfif>
		
		<cfif (greska eq 0)>
			<cfif (Val(podaci_dokumenta.id_pacijenta[1]) not equal Val(podaci_epizode.id_pacijenta[1]))>
				<cfset greska = 1>
				<cfset poruka = poruka & "Izabrana epizoda i dokument ne pripadaju istom pacijentu. ">
			</cfif>
		</cfif>
		
		<cfif (greska eq 0)>
			<cfquery name="update_dokumenta" datasource="#SESSION.baza_podataka#">
				UPDATE dokumenti 
				SET 
					id_epizode = #Val(arguments.id_epizode)# 
				WHERE dokumenti.id = #Val(arguments.id_dokumenta)#
			</cfquery>

			<!--- Ako je izis uputnica prijemna onda treba mijenjati epizode--->
			<cfif Val(podaci_dokumenta.id_forme[1]) EQ 762 >
				<cfquery name="qStaraEpizoda" datasource="#SESSION.baza_podataka#">
					SELECT 
						epizoda.id,
						epizoda.id_pacijenta,
						epizoda.broj_epizode,
						epizoda.datum_od,
						epizoda.datum_do,
						epizoda.ihe_uputnica_unique_id, 
						epizoda.ihe_uputnica_tip, 
						epizoda.ihe_uputnica_id_dokumenta
					FROM epizoda 
					WHERE epizoda.id = #Val(podaci_dokumenta.id_epizode[1])#
				</cfquery>

				<cfquery name="qUpd" datasource="#SESSION.baza_podataka#">
					UPDATE epizoda
					SET ihe_uputnica_unique_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qStaraEpizoda.ihe_uputnica_unique_id[1]#">,
					ihe_uputnica_tip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qStaraEpizoda.ihe_uputnica_tip[1]#">,
					ihe_uputnica_id_dokumenta = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#qStaraEpizoda.ihe_uputnica_id_dokumenta[1]#">
					WHERE id = #Val(arguments.id_epizode)# 
				</cfquery>

				<cfquery name="qUpd" datasource="#SESSION.baza_podataka#">
					UPDATE epizoda
					SET ihe_uputnica_unique_id = NULL,
					ihe_uputnica_tip = NULL,
					ihe_uputnica_id_dokumenta = NULL
					WHERE id = #Val(podaci_dokumenta.id_epizode[1])# 
				</cfquery>




				<cfset odgovor.st_epizoda_id = #Val(podaci_dokumenta.id_epizode[1])#>
				<cfset odgovor.st_epizoda = qStaraEpizoda>
				<cfset odgovor.nova_epizoda_id = #Val(arguments.id_epizode)#>
				<cfset odgovor.nova_epizoda = podaci_epizode>
			</cfif>
		</cfif>
		
		<cfset odgovor.greska = greska>
		<cfset odgovor.poruka = poruka>
		<cfreturn odgovor>
	</cffunction>
</cfcomponent>
