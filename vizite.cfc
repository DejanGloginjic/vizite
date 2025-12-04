<cfcomponent displayname="vizite">
    <cfinclude template="../cffunkcije.cfm">

    <!---<cfset SESSION.baza_podataka = "kiss">
    <cfset SESSION.id_korisnika = 15>
    <cfset SESSION.organizacija = 1000>
    <cfif structKeyExists(server, "cgi") AND structKeyExists(cgi, "request_method") AND cgi.request_method EQ "OPTIONS">
        <cfheader name="Access-Control-Allow-Origin" value="http://localhost:5173">
        <cfheader name="Access-Control-Allow-Credentials" value="true">
        <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
        <cfheader name="Access-Control-Allow-Headers" value="Content-Type">
        <cfheader name="Access-Control-Max-Age" value="86400">
        <cfabort>
    </cfif>

    <cfheader name="Access-Control-Allow-Origin" value="http://localhost:5173">
    <cfheader name="Access-Control-Allow-Credentials" value="true">
    <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
    <cfheader name="Access-Control-Allow-Headers" value="Content-Type">
    <cfheader name="Access-Control-Max-Age" value="86400">--->

    <!-- Pomocna funkcija: Query to Array -->
    <cffunction name="QueryToArray" access="public" output="false" returntype="array">
        <cfargument name="queryObject" type="query">
        <cfset var rows = [] />
        <cfscript>
            for (var s in arguments.queryObject) {
                arrayAppend(rows, s);
            }
        </cfscript>
        <cfreturn rows />
    </cffunction>

    <cffunction name="QueryRowToStruct" access="public" output="false" returntype="struct">
        <cfargument name="q"   type="query"  required="yes">
        <cfargument name="row" type="numeric" required="no" default="1">
        <cfset var s = StructNew()>
        <cfif arguments.q.recordCount GTE arguments.row AND arguments.row GT 0>
            <cfloop list="#arguments.q.columnList#" index="col">
                <cfset s[col] = arguments.q[col][ arguments.row ]>
            </cfloop>
        </cfif>
        <cfreturn s>
    </cffunction>

    <!-- Vraca podatke o sesiji -->
    <cffunction name="get_session" returntype="struct" returnformat="json" access="remote">
        <cfreturn SESSION>
    </cffunction>

    <!-- =========================
         ŠIFRARNICI / POMOĆNE
         ========================= -->

    <!-- Sve sobe za izabrano skladište iz sesije -->
    <cffunction name="getRooms" access="remote" returntype="array" returnformat="json">
        <cfset var q         = "" />
        <cfset var result    = [] />
        <cfset var skladisteId = Val(SESSION.izabrano_skladiste) />

        <!-- Ako nije izabrano skladište u sesiji, vrati prazan niz -->
        <cfif NOT skladisteId>
            <cfreturn result>
        </cfif>

        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT
                id,
                naziv
            FROM soba
            WHERE skladiste = <cfqueryparam cfsqltype="cf_sql_integer" value="#skladisteId#">
            ORDER BY naziv
        </cfquery>

        <cfset result = QueryToArray(q) />
        <cfreturn result>
    </cffunction>



    <!-- (Opcionalno) Sve vrste zadataka (meta za UI) -->
    <cffunction name="getTaskTypes" access="remote" returntype="array" returnformat="json">
        <cfset var q = "">
        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT
                id,
                id_grupe,
                naziv,
                opis,
                d_vrijednost,
                d_vrijednost_required,
                d_jedinica,
                d_ref_vrijednosti,
                d_onkeyup,
                d_regexp,
                d_ukljuceno,
                d_status,
                d_graf,
                d_graf_min,
                d_graf_max,
                redosljed
            FROM ttd_lista_vrste
            ORDER BY redosljed, id
        </cfquery>
        <cfreturn QueryToArray(q)>
    </cffunction>

    <!-- =========================
         LISTA PACIJENATA
         ========================= -->

<cffunction name="getPatients" access="remote" returntype="any" returnformat="json">
    <cfargument name="soba_id" type="numeric" required="no">
    <cfargument name="date"    type="string"  required="no" default="">

    <cfset var q         = "" />
    <cfset var dt        = "" />
    <cfset var grupaId   = Val(SESSION.izabrana_grupa_skladista) />
    <cfset var skladisteId = Val(SESSION.izabrano_skladiste) />

    <!-- normalizuj datum (trenutno ga ne koristimo, ali ostavljamo zbog API-ja) -->
    <cfif len(arguments.date)>
        <cfset dt = arguments.date>
    <cfelse>
        <cfset dt = DateFormat(now(),"yyyy-mm-dd")>
    </cfif>

    <cftry>
        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT
                p.id,
                p.prezime,
                p.ime,
                p.pol,
                p.datum_rodjenja,

                s.id          AS soba_id,
                s.naziv       AS soba,
                k.id          AS krevet_id,
                k.broj_kreveta,

                0 AS task_total,
                0 AS task_done,
                0 AS task_overdue

            FROM pacijenti p

            JOIN epizoda e
                ON e.id_pacijenta = p.id
                AND (e.datum_do IS NULL OR e.datum_do > NOW())
                <cfif grupaId>
                    AND e.skladiste_grupa = <cfqueryparam cfsqltype="cf_sql_integer" value="#grupaId#">
                </cfif>
                <cfif skladisteId>
                    AND e.skladiste = <cfqueryparam cfsqltype="cf_sql_integer" value="#skladisteId#">
                </cfif>

            JOIN krevet_detalji kd
                ON kd.id_pacijenta = p.id
                AND (kd.datum_do IS NULL OR kd.datum_do > NOW())
                AND kd.id_epizode = e.id

            JOIN krevet k
                ON k.id = kd.id_kreveta

            JOIN soba s
                ON s.id = k.soba_id

            WHERE 1 = 1
            <cfif structKeyExists(arguments, "soba_id") AND len(arguments.soba_id)>
                AND s.id = <cfqueryparam value="#arguments.soba_id#" cfsqltype="cf_sql_integer">
            </cfif>

            ORDER BY s.naziv, k.broj_kreveta, p.prezime, p.ime
        </cfquery>

        <cfreturn QueryToArray(q)>

        <cfcatch type="any">
            <cfset var err = StructNew()>
            <cfset err.ok        = false>
            <cfset err.message   = cfcatch.message>
            <cfset err.detail    = cfcatch.detail>
            <cfset err.type      = cfcatch.type>
            <cfset err.sqlState  = structKeyExists(cfcatch, "SQLState") ? cfcatch.SQLState : "">
            <cfset err.nativeErr = structKeyExists(cfcatch, "NativeErrorCode") ? cfcatch.NativeErrorCode : "">
            <cfset err.queryErr  = structKeyExists(cfcatch, "queryError") ? cfcatch.queryError : "">
            <cfset err.where     = "vizite.cfc/getPatients">

            <cfreturn err>
        </cfcatch>
    </cftry>
</cffunction>






    <!-- Aktivni pacijenti sa AKTIVNOM epizodom + važećim krevetom; opciono filtriranje po sobi -->
    <!---<cffunction name="getPatients" access="remote" returntype="array" returnformat="json">
        <cfargument name="soba_id" type="numeric" required="no">
        <cfset var q = "">

        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT
                p.id,
                p.prezime,
                p.ime,
                p.pol,
                p.datum_rodjenja,
                p.boja,
                p.upozorenje,
                p.id_epizode,            -- aktivna epizoda pacijenta
                s.id   AS soba_id,
                s.naziv AS soba,
                k.id   AS krevet_id,
                k.broj_kreveta
            FROM pacijenti p
            /* Važeći zapis kreveta koji pripada AKTIVNOJ epizodi pacijenta */
            JOIN krevet_detalji kd
                ON  kd.id_pacijenta = p.id
                AND (kd.datum_do IS NULL OR kd.datum_do > NOW())
                AND p.id_epizode IS NOT NULL             /* pacijent ima aktivnu epizodu */
                AND kd.id_epizode = p.id_epizode         /* isti id epizode na krevet_detalji */
            JOIN krevet k ON k.id = kd.id_kreveta
            JOIN soba   s ON s.id = k.soba_id
            WHERE p.id_epizode IS NOT NULL
            <cfif structKeyExists(arguments, "soba_id") AND len(arguments.soba_id)>
                AND s.id = <cfqueryparam value="#arguments.soba_id#" cfsqltype="cf_sql_integer">
            </cfif>
            ORDER BY s.naziv, k.broj_kreveta, p.prezime, p.ime
        </cfquery>

        <cfreturn QueryToArray(q)>
    </cffunction>--->


    <!-- Jedan pacijent + trenutna soba/krevet (za header) -->
    <cffunction name="getPatientById" access="remote" returntype="struct" returnformat="json">
        <cfargument name="patient_id" type="numeric" required="yes">
        <cfset var q = "">
        <cfset var rezultat = StructNew()>
        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT
                p.*,
                s.id   AS soba_id,
                s.naziv AS soba,
                k.id   AS krevet_id,
                k.broj_kreveta
            FROM pacijenti p
            LEFT JOIN krevet_detalji kd
                   ON kd.id_pacijenta = p.id
                  AND (kd.datum_do IS NULL OR kd.datum_do > NOW())
            LEFT JOIN krevet k ON k.id = kd.id_kreveta
            LEFT JOIN soba   s ON s.id = k.soba_id
            WHERE p.id = <cfqueryparam value="#arguments.patient_id#" cfsqltype="cf_sql_integer">
            LIMIT 1
        </cfquery>
        <cfif q.recordCount>
            <cfset rezultat = QueryRowToStruct(q, 1)>
        </cfif>
        <cfreturn rezultat>
    </cffunction>



    <!-- Jedan pacijent + trenutna soba/krevet (za header) -->
    <cffunction name="getPatientByWirstband" access="remote" returntype="struct" returnformat="json">
        <cfargument name="patient_id" type="numeric" required="yes">
        <cfset var q = "">
        <cfset var rezultat = StructNew()>
        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT
                p.*,
                s.id   AS soba_id,
                s.naziv AS soba,
                k.id   AS krevet_id,
                k.broj_kreveta
            FROM pacijenti p
            LEFT JOIN krevet_detalji kd
                   ON kd.id_pacijenta = p.id
                  AND (kd.datum_do IS NULL OR kd.datum_do > NOW())
            LEFT JOIN krevet k ON k.id = kd.id_kreveta
            LEFT JOIN soba   s ON s.id = k.soba_id
            WHERE p.id = <cfqueryparam value="#arguments.patient_id#" cfsqltype="cf_sql_integer">
            LIMIT 1
        </cfquery>
        <cfif q.recordCount>
            <cfset rezultat = QueryRowToStruct(q, 1)>
        </cfif>
        <cfreturn rezultat>
    </cffunction>


    <!-- =========================
         ZADACI PACIJENTA
         ========================= -->

    <!-- Zadaci za pacijenta za dati dan (default: danas) -->
    <cffunction name="getPatientTasks" access="remote" returntype="array" returnformat="json">
        <cfargument name="patient_id" type="numeric" required="yes">
        <cfargument name="date" type="string" required="no" default="">
        <cfset var q = "">
        <cfset var dt = "">
        <!-- normalizuj datum -->
        <cfif len(arguments.date)>
            <cfset dt = arguments.date>
        <cfelse>
            <cfset dt = DateFormat(now(),"yyyy-mm-dd")>
        </cfif>

        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT 
                d.id,
                d.id_vrste,
                v.naziv,
                v.d_vrijednost_required,
                v.d_jedinica,
                v.d_ref_vrijednosti,
                d.kolicina,
                d.vrijednost,
                d.jedinica,
                d.status,
                d.datum
            FROM ttd_lista_sadrzaj_detalji d
            LEFT JOIN ttd_lista_vrste v ON v.id = d.id_vrste
            WHERE d.id_pacijenta = <cfqueryparam value="#arguments.patient_id#" cfsqltype="cf_sql_integer">
            AND DATE(d.datum)  = <cfqueryparam value="#dt#" cfsqltype="cf_sql_date">
            AND d.obrisano     = 0
            ORDER BY v.redosljed ASC, d.id ASC
        </cfquery>

        <cfreturn QueryToArray(q)>
    </cffunction>


    <!-- (Opcionalno) Zadaci po opsegu datuma – za eventualne izvještaje/istoriju u UI -->
    <cffunction name="getPatientTasksRange" access="remote" returntype="array" returnformat="json">
        <cfargument name="patient_id" type="numeric" required="yes">
        <cfargument name="start_date" type="string"  required="yes"> <!-- 'YYYY-MM-DD' -->
        <cfargument name="end_date"   type="string"  required="yes"> <!-- 'YYYY-MM-DD' (uključivo) -->
        <cfset var q = "">
        <cfset var ds = createDateTime( val(Left(arguments.start_date,4)), val(Mid(arguments.start_date,6,2)), val(Right(arguments.start_date,2)), 0,0,0 )>
        <cfset var de = dateAdd("d", 1, createDateTime( val(Left(arguments.end_date,4)), val(Mid(arguments.end_date,6,2)), val(Right(arguments.end_date,2)), 0,0,0 ))>

        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT
                d.id,
                d.id_vrste,
                v.naziv,
                v.opis,
                v.d_vrijednost_required,
                v.d_jedinica,
                v.d_regexp,
                v.d_graf_min,
                v.d_graf_max,
                v.redosljed,
                d.vrijednost,
                d.jedinica,
                d.status,
                d.napomena,
                d.status_promjena,
                d.datum
            FROM ttd_lista_sadrzaj_detalji d
            JOIN ttd_lista_vrste v ON v.id = d.id_vrste
            WHERE d.id_pacijenta = <cfqueryparam value="#arguments.patient_id#" cfsqltype="cf_sql_integer">
              AND d.obrisano = 0
              AND d.datum >= <cfqueryparam value="#ds#" cfsqltype="cf_sql_timestamp">
              AND d.datum <  <cfqueryparam value="#de#" cfsqltype="cf_sql_timestamp">
            ORDER BY d.datum ASC, v.redosljed, d.id
        </cfquery>

        <cfreturn QueryToArray(q)>
    </cffunction>

<cffunction name="lista_skladista_korisnika" access="remote" returntype="array" returnformat="json"
    hint="Vraća sve skladiste_grupa i njihova skladista za trenutnog korisnika iz sesije.">

    <cfset var userId    = Val(SESSION.id_korisnika) />
    <cfset var qData     = "" />
    <cfset var groups    = [] />
    <cfset var groupsMap = StructNew() />
    <cfset var gid       = 0 />
    <cfset var g         = "" />
    <cfset var s         = "" />

    <!-- Ako nema korisnika u sesiji, vrati prazan niz -->
    <cfif NOT userId>
        <cfreturn groups>
    </cfif>

    <!-- 1) Povuci grupe + skladišta za tog korisnika -->
    <cfquery name="qData" datasource="#SESSION.baza_podataka#">
        SELECT DISTINCT
            g.ID                     AS grupa_id,
            g.naziv                  AS grupa_naziv,
            g.opis                   AS grupa_opis,
            g.adresa                 AS grupa_adresa,

            s.ID                     AS skladiste_id,
            s.naziv                  AS skladiste_naziv,
            s.adresa                 AS skladiste_adresa,
            s.aktivno                AS skladiste_aktivno

        FROM conf_korisnici_organizacione_jedinice ku
        INNER JOIN skladiste_grupa g
            ON g.ID = ku.id_organizacione_jedinice
        LEFT JOIN skladiste s
            ON s.ID_grupe = g.ID

        WHERE ku.id_korisnika = <cfqueryparam cfsqltype="cf_sql_integer" value="#userId#">
        AND s.aktivno = 1

        ORDER BY g.naziv, s.naziv
    </cfquery>

    <!-- 2) Grupisanje: jedna grupa -> niz skladišta -->
    <cfloop query="qData">
        <cfset gid = qData.grupa_id />

        <!-- ako grupa još nije dodana, kreiraj je -->
        <cfif NOT StructKeyExists(groupsMap, gid)>
            <cfset g = StructNew() />
            <cfset g.id        = qData.grupa_id />
            <cfset g.naziv     = qData.grupa_naziv />
            <cfset g.opis      = qData.grupa_opis />
            <cfset g.adresa    = qData.grupa_adresa />
            <!-- ovdje nemamo g.aktivno u bazi, pa ili ga preskačemo ili hard-code 1 -->
            <cfset g.aktivno   = 1 />
            <cfset g.skladista = [] />

            <cfset ArrayAppend(groups, g) />
            <cfset groupsMap[gid] = g />
        </cfif>

        <!-- ako postoji skladište, dodaj ga u listu -->
        <cfif Len(qData.skladiste_id & "")>
            <cfset s = StructNew() />
            <cfset s.id        = qData.skladiste_id />
            <cfset s.naziv     = qData.skladiste_naziv />
            <cfset s.adresa    = qData.skladiste_adresa />
            <cfset s.aktivno   = qData.skladiste_aktivno />

            <cfset ArrayAppend(groupsMap[gid].skladista, s) />
        </cfif>
    </cfloop>

    <!-- 3) Vrati JSON array -->
    <cfreturn groups>
</cffunction>


<cffunction name="setWorkingLocation" access="remote" returntype="struct" returnformat="json"
    hint="Postavlja izabranu grupu skladišta i skladište u SESSION.">
    <cfargument name="grupa_id"     type="numeric" required="yes">
    <cfargument name="skladiste_id" type="numeric" required="yes">

    <cfset var res = StructNew() />

    <!-- Normalizuj vrijednosti -->
    <cfset SESSION.izabrana_grupa_skladista = Val(arguments.grupa_id) />
    <cfset SESSION.izabrano_skladiste       = Val(arguments.skladiste_id) />

    <!-- Po želji možeš ovdje dodati još logike (npr. provjera da li skladište pripada grupi) -->

    <cfset res.ok                         = true />
    <cfset res.izabrana_grupa_skladista   = SESSION.izabrana_grupa_skladista />
    <cfset res.izabrano_skladiste         = SESSION.izabrano_skladiste />

    <cfreturn res />
</cffunction>

<cffunction name="getPatientDocuments" access="remote" returntype="any" returnformat="json"
    hint="Vraća dokumente pacijenta, grupisane po epizodi (sa osnovnim metapodacima).">
    <cfargument name="patient_id" type="numeric" required="yes">
    <!-- opcioni filteri, za kasnije proširenje -->
    <cfargument name="date_from"  type="string"  required="no" default="">
    <cfargument name="date_to"    type="string"  required="no" default="">
    <cfargument name="episode_id" type="numeric" required="no">

    <cfset var q  = "" />
    <cfset var df = "" />
    <cfset var dt = "" />

    <!-- normalizuj datume, ako su poslati -->
    <cfif len(arguments.date_from)>
        <cfset df = arguments.date_from />
    </cfif>
    <cfif len(arguments.date_to)>
        <cfset dt = arguments.date_to />
    </cfif>

    <cftry>
        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT
                d.id,
                d.id_pacijenta,
                d.id_epizode,
                d.id_forme,
                d.datum_kreiranja,
                d.sazetak,

                e.broj_epizode,
                e.datum_od,
                e.datum_do,

                f.naslov,
                ku.potpis                 AS korisnik_potpis,

                sg.naziv                  AS skladiste_grupa_naziv,
                s.id                      AS skladiste_id

            FROM dokumenti d
            LEFT JOIN forma        f  ON f.id = d.id_forme
            LEFT JOIN epizoda      e  ON e.id = d.id_epizode
            LEFT JOIN conf_korisnici ku ON ku.id = d.id_korisnika
            LEFT JOIN skladiste_grupa sg ON sg.id = e.skladiste_grupa
            LEFT JOIN skladiste    s  ON s.id = e.skladiste

            WHERE d.obrisano = 0
              AND d.id_pacijenta = <cfqueryparam value="#arguments.patient_id#" cfsqltype="cf_sql_integer">

            <cfif structKeyExists(arguments, "episode_id") AND len(arguments.episode_id)>
              AND d.id_epizode = <cfqueryparam value="#arguments.episode_id#" cfsqltype="cf_sql_integer">
            </cfif>

            <cfif len(df)>
              AND DATE(d.datum_kreiranja) >= <cfqueryparam value="#df#" cfsqltype="cf_sql_date">
            </cfif>

            <cfif len(dt)>
              AND DATE(d.datum_kreiranja) <= <cfqueryparam value="#dt#" cfsqltype="cf_sql_date">
            </cfif>

            ORDER BY d.datum_kreiranja DESC, d.id DESC
        </cfquery>

        <cfreturn QueryToArray(q) />

        <cfcatch type="any">
            <cfset var err = StructNew()>
            <cfset err.ok        = false>
            <cfset err.message   = cfcatch.message>
            <cfset err.detail    = cfcatch.detail>
            <cfset err.type      = cfcatch.type>
            <cfset err.sqlState  = structKeyExists(cfcatch, "SQLState") ? cfcatch.SQLState : "">
            <cfset err.nativeErr = structKeyExists(cfcatch, "NativeErrorCode") ? cfcatch.NativeErrorCode : "">
            <cfset err.queryErr  = structKeyExists(cfcatch, "queryError") ? cfcatch.queryError : "">
            <cfset err.where     = "vizite.cfc/getPatientDocuments">

            <cfreturn err>
        </cfcatch>
    </cftry>
</cffunction>

<cffunction name="lista_epizoda_pacijenta"
           access="remote"
           returntype="void"
           returnformat="json"
           hint="Vraća sve epizode za datog pacijenta.">
  <cfargument name="pacijent_id" type="string" required="yes">

  <cftry>
    <cfset var pid = Val(arguments.pacijent_id)>

    <cfif NOT pid>
      <cfset fail(
        code   = "BAD_REQUEST",
        message= "Nedostaje ili je neispravan pacijent_id.",
        status = 400
      )>
    </cfif>

    <cfquery name="qEp" datasource="#SESSION.baza_podataka#">
      SELECT
        e.id          AS id_epizode,
        e.pacijent_id,
        e.broj_epizode,
        e.datum_od,
        e.datum_do
      FROM epizoda_pacijenta e
      WHERE e.pacijent_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#pid#">
      ORDER BY
        e.datum_od DESC,
        e.id DESC
    </cfquery>

    <!--- pretpostavljam da već imaš QueryToArray + ok/fail helper-e kao u drugim CFC-ovima --->
    <cfset ok(
      data = QueryToArray(qEp)
    )>
    
    <cfcatch type="any">
      <cfset fail(
        code   = "SERVER_ERROR",
        message= "Greška pri učitavanju epizoda pacijenta: " & cfcatch.message,
        status = 500
      )>
    </cfcatch>
  </cftry>
</cffunction>


</cfcomponent>
