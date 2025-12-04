<cfprocessingdirective pageEncoding="utf-8"><!--- šđčžćŠĐČĆŽ --->
<cfprocessingdirective suppresswhitespace="yes">

<cfset SESSION.izabrana_grupa_skladista = 0>
<cfset SESSION.izabrano_skladiste = 0>
<cfset SESSION.aplikacija = "">
<cfset SESSION.nacin_rada = "">

<!---cfscript>
    // Kreiramo instancu Java klase TimeZone
    var timeZone = createObject("java", "java.util.TimeZone").getDefault().getID();
    // Ispisujemo trenutnu vremensku zonu
    writeOutput(timeZone);
</cfscript--->

<cfobject name="message" component="#avar_relfolder#.support.message">
<cfset msg_support = 0>
<cftry>
	<cfset msg_check_response1 = message.msg_check(SESSION.id_korisnika, 3)>
	<cfif (msg_check_response1.error eq 0)>
		<cfset msg_support = Val(msg_check_response1.count)>
	</cfif>
	<cfcatch type="any">
	</cfcatch>
</cftry>

<cfset tmp_ulaz_administracija = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 2) GTE 1)>
	<cfset tmp_ulaz_administracija = 1>
</cfif>

<cfset tmp_ulaz_klinika = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 3) GTE 1)>
	<cfset tmp_ulaz_klinika = 1>
</cfif>

<cfset tmp_ulaz_apoteka = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 4) GTE 1)>
	<cfset tmp_ulaz_apoteka = 1>
</cfif>

<cfset tmp_ulaz_uprava = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 5) GTE 1)>
	<cfset tmp_ulaz_uprava = 1>
</cfif>

<cfset tmp_trazi_pacijenta = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 7) GTE 1)>
	<cfset tmp_trazi_pacijenta = 1>
</cfif>

<cfset tmp_provjera_osiguranja = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 8) GTE 1)>
	<cfset tmp_provjera_osiguranja = 1>
</cfif>

<cfset tmp_kuhinja = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 12) GTE 1)>
	<cfset tmp_kuhinja = 1>
</cfif>

<cfset tmp_labaratorija = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 23) GTE 1)>
	<cfset tmp_labaratorija = 1>
</cfif>

<cfset tmp_hospitalizacije = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 19) GTE 1)>
	<cfset tmp_hospitalizacije = 1>
</cfif>

<cfset tmp_studije = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 18) GTE 1)>
	<cfset tmp_studije = 1>
</cfif>

<cfset tmp_dokumenti = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.funkcija_korisnika, 35) GTE 1)>
	<cfset tmp_dokumenti = 1>
</cfif>

<cfset tmp_dezurstva = 0>
<!--- <cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 11) GTE 1) OR (ListFindNoCase(SESSION.funkcija_korisnika, 14) GTE 1)> --->

<!--- gk1 Administratori , gk11 dezurstva, fk15 direktori --->
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 11) GTE 1) OR (ListFindNoCase(SESSION.funkcija_korisnika, 15) GTE 1) OR (ListFindNoCase(SESSION.funkcija_korisnika, 14) GTE 1) OR (ListFindNoCase(SESSION.funkcija_korisnika, 11) GTE 1)>
	<cfset tmp_dezurstva = 1>
</cfif>

<cfset tmp_sihterica = 0>
<cfif (ListFindNoCase(SESSION.funkcija_korisnika, 42) GTE 1) OR (ListFindNoCase(SESSION.funkcija_korisnika, 44) GTE 1) OR (ListFindNoCase(SESSION.funkcija_korisnika, 45) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 13) GTE 1)>
	<cfset tmp_sihterica = 1>
</cfif>

<cfset tmp_protokol = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 14) GTE 1)>
	<cfset tmp_protokol = 1>
</cfif>

<cfset tmp_cekaonice = 1>
<cfset tmp_support = 1>
<cfset tmp_ikt = 1>
	
<cfset tmp_kadrovska = 0>
<cfif (ListFindNoCase(SESSION.grupa_korisnika, 1) GTE 1) OR (ListFindNoCase(SESSION.grupa_korisnika, 2) GTE 1)>
	<cfset tmp_kadrovska = 1>
</cfif>

<cfif (ListFindNoCase(SESSION.grupa_korisnika, 15) GTE 1)>
	<cfset tmp_cekaonice = 0>
	<cfset tmp_support = 0>
	<cfset tmp_ikt = 0>
</cfif>

<cfset onclick_klinika = 0>
<cfset onclick_odjel = 0>

<cfif (tmp_ulaz_klinika eq 1)>
	<cfquery name="pridruzene_organizacije" datasource="#SESSION.baza_podataka#">
		SELECT 
			conf_korisnici_organizacione_jedinice.id_organizacione_jedinice, 
            conf_organizacione_jedinice.naziv AS naziv_organizacione_jedinice, 
			conf_organizacione_jedinice.sifra 
		FROM conf_korisnici_organizacione_jedinice 
		LEFT JOIN conf_organizacione_jedinice ON conf_organizacione_jedinice.id = conf_korisnici_organizacione_jedinice.id_organizacione_jedinice  
		WHERE conf_korisnici_organizacione_jedinice.id_korisnika = #Val(SESSION.id_korisnika)# 
	</cfquery>
	<cfif (pridruzene_organizacije.recordCount eq 1)>
		<cfset onclick_klinika = Val(pridruzene_organizacije.id_organizacione_jedinice[1])>
	<cfelseif (pridruzene_organizacije.recordCount GTE 2)>
		<cfif (Val(SESSION.organizacija) not equal 0)>
			<cfset onclick_klinika = Val(SESSION.organizacija)>
		<cfelse>
			<cfquery name="podaci_korisnika" datasource="#SESSION.baza_podataka#">
				SELECT 
					conf_korisnici.def_skladiste_grupa, 
					conf_korisnici.def_skladiste  
				FROM conf_korisnici 
				WHERE conf_korisnici.id = #Val(SESSION.id_korisnika)# 
			</cfquery>
			<cfif (Val(podaci_korisnika.def_skladiste_grupa[1]) not equal 0)>
				<cfset onclick_klinika = Val(podaci_korisnika.def_skladiste_grupa[1])>
			</cfif>
		</cfif>
	</cfif>
	
	<cfif (onclick_klinika not equal 0)>
		<cfquery name="pridruzena_skladista" datasource="#SESSION.baza_podataka#">
			SELECT 
				skladiste.ID AS id, 
				skladiste.naziv 
			FROM skladiste 
			WHERE skladiste.ID_grupe = #Val(onclick_klinika)# 
			AND skladiste.aktivno = 1 
		</cfquery>
		<cfif (pridruzena_skladista.recordCount eq 1)>
			<cfset onclick_odjel = Val(pridruzena_skladista.id[1])>
		</cfif>
	</cfif>
</cfif>

<cfquery name="obavjestenja" datasource="#SESSION.baza_podataka#">
	SELECT 
		reklame.id, 
		reklame.datum_od,
		reklame.naslov, 
		reklame.sadrzaj
	FROM reklame 
	WHERE reklame.datum_od < '#DateFormat(now(), "yyyy-mm-dd")# #TimeFormat(now(),"HH:mm:ss")#' 
	AND ((reklame.datum_do > '#DateFormat(now(), "yyyy-mm-dd")# #TimeFormat(now(),"HH:mm:ss")#') OR (reklame.datum_do IS NULL) OR (reklame.datum_do is NULL)) 
	ORDER BY reklame.redoslijed ASC 
</cfquery>





<!DOCTYPE html>
<html>
<head>
	<cfoutput>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<meta charset="utf-8">
	<link rel="shortcut icon" href="#avar_livesite#images/favicon.ico" type="image/x-icon" />
	<title>#avar_aplikacija_naziv# :: Početna strana</title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<script type="text/javascript" src="#avar_livesite#scripts/engine.js"></script>
	<script type="text/javascript" src="#avar_livesite#scripts/global.js"></script>
	<link href="#avar_livesite#css/main.css" rel="stylesheet" type="text/css" />
	<link href="#avar_livesite#css/fontawesome4.6.3.css" rel="stylesheet" type="text/css">
	<link class="main-stylesheet" href="#avar_livesite#css/hello.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" type="text/css" href="#avar_livesite#css/bootstrap-grid.css" />
	<link href="#avar_livesite#css/site.css" rel="stylesheet" type="text/css" />

	<!--- Ako je mobilni uredjaj ucitaj i ovaj css - veca dugmad na izboru klinika --->
	<cfif reFindNoCase("android|android.+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino",CGI.HTTP_USER_AGENT) GT 0 OR reFindNoCase("1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|e\-|e\/|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|xda(\-|2|g)|yas\-|your|zeto|zte\-",Left(CGI.HTTP_USER_AGENT,4)) GT 0>

		
		<link href="#avar_livesite#css/site.css" rel="stylesheet" type="text/css" />
	</cfif>
	</cfoutput>
</head>

<body>
	<!--- šifrarnik, layer i popup --->
	<cfinclude template="template_layer.cfm">

	<cfoutput>
	<div class="page-container">
		<div class="page-content-wrapper">
			<div class="content sm-gutter">
				<div class="padding-25 sm-padding-10">
					<div class="row">
						
						<!--- lijeva kolona --->
						<div class="col-md-6 col-xlg-4 col-lg-4">

							<!--- prvi red --->
							<div class="row">
								<div class="col-sm-6 m-b-10">
									<div class="ar-1-1">
										<div class="widget-2 panel no-border bg-primary widget no-margin<cfif (tmp_ulaz_klinika eq 0)> disabled</cfif>"<cfif (tmp_ulaz_klinika eq 1)><cfif ((onclick_klinika not equal 0) AND (onclick_odjel not equal 0))> onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=bisa_2&organizacija=#onclick_klinika#&organizacija_odjel=#onclick_odjel#&nacin_rada=ambulanta';"<cfelse> onclick="organizacija_ajax_ucitaj('#onclick_klinika#'); nacin_rada='ambulanta';"</cfif></cfif>>
											<div class="panel-body no-padding">
												<div class="padding-30">
													<div class="pull-bottom p-b-20">
														<h3 class="no-margin text-white">AMBULANTA</h3>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>

								<div class="col-sm-6 m-b-10">
									<div class="ar-1-1">
										<div class="widget-3 panel no-border bg-complete widget no-margin<cfif (tmp_ulaz_klinika eq 0)> disabled</cfif>"<cfif (tmp_ulaz_klinika eq 1)><cfif ((onclick_klinika not equal 0) AND (onclick_odjel not equal 0))> onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=bisa_2&organizacija=#onclick_klinika#&organizacija_odjel=#onclick_odjel#&nacin_rada=klinika';"<cfelse> onclick="organizacija_ajax_ucitaj('#onclick_klinika#'); nacin_rada='klinika';"</cfif></cfif>>
											<div class="panel-body no-padding">
												<div class="padding-30">
													<div class="pull-bottom p-b-20">
														<h3 class="no-margin text-white">KLINIKA</h3>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>

							<!--- drugi red --->
							<div class="row">
								<div class="col-sm-6 m-b-10">
									<div class="ar-1-1">
										<div class="widget-6 panel no-border bg-master widget no-margin<cfif (tmp_ulaz_apoteka eq 0)> disabled</cfif>"<cfif (tmp_ulaz_apoteka eq 1)> onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=&nacin_rada=apoteka&organizacija=#apoteka_var_maticna_grupa_skladista#&organizacija_odjel=0';"</cfif>>
											<div class="panel-body no-padding">
												<div class="padding-30">
													<div class="pull-bottom p-b-20">
														<h3 class="no-margin text-white">APOTEKA</h3>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>

								<div class="col-sm-6 m-b-10">
									<div class="ar-1-1">
										<div class="widget-7 panel no-border bg-success widget no-margin<cfif (tmp_ulaz_uprava eq 0)> disabled</cfif>"<cfif (tmp_ulaz_uprava eq 1)> onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=uprava&nacin_rada=uprava';"</cfif>>
											<div class="panel-body no-padding">
												<div class="padding-30">
													<div class="pull-bottom p-b-20">
														<h3 class="no-margin text-white">UPRAVA</h3>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>

						</div>
						<!--- kraj: lijeva kolona --->

						<!--- desna kolona --->
						<div class="col-md-6 col-xlg-5 col-lg-8">

							<!--- prvi red --->
							<div class="row">
								<div class="col-md-12 m-b-10 visina_panela">
									<div class="ar-3-2 widget-1-wrapper">
										<div class="widget-1 panel no-border bg-complete-light no-margin">
											<div class="panel-heading top-right">
												<a href="#avar_livesite#logoff.cfm" class="header-toolbar" title="...izlaz iz programa"><i class="fa fa-power-off"></i><br /><b>IZLAZ</b></a>
											</div>
											<div class="panel-body">
												<div class="top-left top-right padding-25 text-white fs-16 text-shadow">
													<div class="panel-title">OBAVJEŠTENJA</div>
													<ul>
														<cfloop query="obavjestenja">
															<li>#DateFormat(obavjestenja.datum_od, "dd.mm.yyyy")# | #obavjestenja.naslov# <cfif (obavjestenja.sadrzaj not equal "")><br />#obavjestenja.sadrzaj#</cfif></li>
														</cfloop>
													</ul>
													<cftry>
														<cfset msg_check_response2 = message.msg_check(SESSION.id_korisnika, 2)>
														<cfif (msg_check_response2.error eq 1)>
															<cfoutput>#msg_check_response2.message#</cfoutput>
														<cfelse>
															<cfoutput>#msg_check_response2.data#</cfoutput>
														</cfif>
														<cfcatch type="any">
															<cfoutput>#cfcatch.Message# #cfcatch.detail#</cfoutput>
														</cfcatch>
													</cftry>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>

							<!--- drugi red --->
							<div class="row">
								<div class="col-sm-4 col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-51 panel no-border"<cfif (tmp_trazi_pacijenta eq 1)>  onclick="document.location.href='#avar_livesite#info_pacijent.cfm';"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_trazi_pacijenta eq 0)> disabled</cfif>"><i class="fa fa-group"></i> TRAŽI PACIJENTA</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
								<div class="col-sm-4  col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-52 panel no-border"<cfif (tmp_cekaonice eq 1)> onclick="document.location.href='#avar_livesite#administracija/timeline_pregled.cfm';"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_cekaonice eq 0)> disabled</cfif>"><i class="fa fa-calendar"></i> ČEKAONICE</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>								
								<div class="col-sm-4  col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-53 panel no-border"<cfif (tmp_dokumenti eq 1)> onclick="document.location.href='#avar_livesite#amb_dokumenti.cfm';"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_dokumenti eq 0)> disabled</cfif>"><i class="fa fa-files-o"></i> DOKUMENTI</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>							
							<!--- treći red --->
							<div class="row">
								<div class="col-sm-4 col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-54 panel no-border"<cfif (tmp_provjera_osiguranja eq 1)> onclick="document.location.href='#avar_livesite#provjera_osiguranja.cfm';"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_provjera_osiguranja eq 0)> disabled</cfif>"><i class="fa fa-bookmark-o"></i> PROVJERA OSIGURANJA</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
								<div class="col-sm-4 col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-55 panel no-border"<cfif (tmp_support eq 1)> onclick="document.location.href='#avar_livesite#support/msg_support.cfm';"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_support eq 0)> disabled</cfif>"<cfif (msg_support not equal 0)> title="...imate ukupno #msg_support# nepročitanih obavještenja"</cfif>><i class="fa fa-question-circle-o"></i> #prevod("POMOĆ I PODRŠKA")#<cfif (msg_support not equal 0)><span style="float:right; font-size:12px !important; line-height:12px !important; font-weight:bold; color:##FFF !important; background-color:##F00; padding:2px !important;">#msg_support#</span></cfif></h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>							
								<div class="col-sm-4 col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-56 panel no-border"<cfif (tmp_ulaz_administracija eq 1)> onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=administracija&nacin_rada=administracija'"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_ulaz_administracija eq 0)> disabled</cfif>"><i class="fa fa-gears"></i> ADMINISTRACIJA</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>							
							<!--- cetvrti red --->
							<div class="row">
								<div class="col-sm-4 col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-54 panel no-border"<cfif (tmp_kuhinja eq 1)> onclick="document.location.href='#avar_livesite#ishrana2/index.html';"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_kuhinja eq 0)> disabled</cfif>"><i class="fa fa-cutlery"></i> KUHINJA</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
								<div class="col-sm-4 col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-54 panel no-border"<cfif (tmp_labaratorija eq 1)> onclick="document.location.href='#avar_livesite#laboratorija/index.html';"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_labaratorija eq 0)> disabled</cfif>"><i class="fa fa-user-md"></i>LABORATORIJA - LIS</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
								<!---div class="col-sm-4 col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-54 panel no-border"<cfif (tmp_labaratorija eq 1)> onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=bisa_2&organizacija=1204&organizacija_odjel=12049&nacin_rada=klinika';"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_labaratorija eq 0)> disabled</cfif>"><i class="fa fa-user-md"></i>LABORATORIJA - LIS</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div--->
								<div class="col-sm-4 col-md-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-55 panel no-border"<cfif (tmp_ikt eq 1)> onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=bisa_2&organizacija=1000&organizacija_odjel=10008&nacin_rada=klinika';"</cfif>>
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin<cfif (tmp_ikt eq 0)> disabled</cfif>"><i class="fa fa-desktop"></i> IKT SLUŽBA - SERVIS</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>								
							</div>

							
							<!--- peti red  više od 3 u redu--->
							<div class="row">
							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-56 panel no-border" onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=bisa_2&organizacija=1261&organizacija_odjel=12611&nacin_rada=klinika';">
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_ulaz_administracija eq 0)> disabled</cfif>">
											<i class="fa fa-wrench"></i> TEHNIČKA SLUŽBA
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-54 panel no-border" onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=bisa_2&organizacija=1000&organizacija_odjel=10010&nacin_rada=klinika';">
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_provjera_osiguranja eq 0)> disabled</cfif>">
											<i class="fa fa-tachometer"></i> ODRŽAVANJE MED. OPREME
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-55 panel no-border"<cfif (tmp_kadrovska eq 1)> onclick="document.location.href='#avar_livesite#pocetna.cfm?aplikacija=kadrovska';"</cfif>>
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_kadrovska eq 0)> disabled</cfif>">
											<i class="fa fa-sitemap"></i> KADROVSKA
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-56 panel no-border" onclick="document.location.href='#avar_livesite#protokol.cfm';">
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_protokol eq 0)> disabled</cfif>">
											<i class="fa fa-list-alt"></i> PROTOKOL
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-54 panel no-border"<cfif (tmp_studije eq 1)> onclick="document.location.href='#avar_livesite#klinicki_studij/index.html';"</cfif>>
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_studije eq 0)> disabled</cfif>">
											<i class="fa fa-flask"></i> KLINIČKE STUDIJE
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-54 panel no-border"<cfif (tmp_hospitalizacije eq 1)> onclick="document.location.href='#avar_livesite#hospitalizacija/index.html';"</cfif>>
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_hospitalizacije eq 0)> disabled</cfif>">
											<i class="fa fa-archive"></i> DRG
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-54 panel no-border"<cfif (tmp_hospitalizacije eq 1)> onclick="document.location.href='#avar_livesite#apo_sihterica/react/index.html';"</cfif>>
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_hospitalizacije eq 0)> disabled</cfif>">
											<i class="fa fa-hourglass-half"></i> APO SIHTERICA
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-54 panel no-border"<cfif (tmp_hospitalizacije eq 1)> onclick="document.location.href='#avar_livesite#interakcije/dist/';"</cfif>>
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_hospitalizacije eq 0)> disabled</cfif>">
											<i class="fa fa-share-alt"></i> INTERAKCIJE
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-54 panel no-border"<cfif (tmp_hospitalizacije eq 1)> onclick="document.location.href='#avar_livesite#fond_uputnice_test/react/';"</cfif>>
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_hospitalizacije eq 0)> disabled</cfif>">
											<i class="fa fa-share-alt"></i> ZAKAZIVANJE
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-54 panel no-border"<cfif (tmp_hospitalizacije eq 1)> onclick="document.location.href='#avar_livesite#fond_lab_izis_kis/dist/';"</cfif>>
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_hospitalizacije eq 0)> disabled</cfif>">
											<i class="fa fa-file-text-o"></i> E-UPUTNICE
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							<!-- VIZITE -->
							<div class="col-sm-4 col-md-4 m-b-10">
								<div class="ar-2-1">
								<div class="widget-54 panel no-border"<cfif (tmp_hospitalizacije eq 1)> onclick="document.location.href='#avar_livesite#vizite/dist/index.html';"</cfif>>
									<div class="container-xs-height full-height">
									<div class="relative">
										<div class="padding-10 top-left">
										<h5 class="hint-text no-margin<cfif (tmp_hospitalizacije eq 0)> disabled</cfif>">
											<i class="fa fa-stethoscope"></i> VIZITE
										</h5>
										</div>
									</div>
									</div>
								</div>
								</div>
							</div>

							</div> <!-- kraj petog reda -->




							<!--- logout red --->
							<div class="row logout">
								<div class="col-sm-4 m-b-10">
									<div class="ar-2-1">
										<div class="widget-57 panel no-border" onclick="document.location.href='#avar_livesite#logoff.cfm'">
											<div class="container-xs-height full-height">
												<div class="relative">
													<div class="padding-10 top-left">
														<h5 class="hint-text no-margin"><i class="fa fa-power-off"></i> IZLAZ</h5>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>

						</div>
						<!--- kraj: desna kolona --->

					</div>
				</div>
			</div>
		</div>
	</div> 
	</cfoutput>
	
	<!--- izbor klinike / odjela --->
	<cfinclude template="organizacija_layer.cfm">
	
	<!--- pomoć --->
	<cfsavecontent variable="help_sadrzaj">
		<iframe id="help_iframe" name="help_iframe" src="" style="width:980px; height:480px; border:none;"></iframe>
	</cfsavecontent>
	<cfset popup_help = render_popup("popup_help", #prevod("Pomoć")#, #help_sadrzaj#)>
	
</body>
</html>
</cfprocessingdirective>
