<cfcomponent displayname="vizite">
    <cfinclude template="../cffunkcije.cfm">

    <cfset SESSION.baza_podataka = "ambulanta_zlatno_doba">
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
    <cfheader name="Access-Control-Max-Age" value="86400">

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

    <!-- Sve sobe (za filter) -->
    <cffunction name="getRooms" access="remote" returntype="array" returnformat="json">
        <cfset var q = "">
        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT id, naziv
            FROM soba
            ORDER BY naziv
        </cfquery>
        <cfreturn QueryToArray(q)>
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

    <!-- Aktivni pacijenti + summariji zadataka za dati dan -->
    <cffunction name="getPatients" access="remote" returntype="array" returnformat="json">
        <cfargument name="soba_id" type="numeric" required="no">
        <cfargument name="date"    type="string"  required="no" default="">
        <cfset var q  = "">
        <cfset var dt = "">

        <!-- normalizuj datum -->
        <cfif len(arguments.date)>
            <cfset dt = arguments.date>
        <cfelse>
            <cfset dt = DateFormat(now(),"yyyy-mm-dd")>
        </cfif>

        <cfquery name="q" datasource="#SESSION.baza_podataka#">
            SELECT
                p.id,
                p.prezime,
                p.ime,
                p.pol,
                p.datum_rodjenja,
                p.boja,
                p.upozorenje,
                s.id  AS soba_id,
                s.naziv AS soba,
                k.id  AS krevet_id,
                k.broj_kreveta,

                /* --- sažetak zadataka za dan dt --- */
                IFNULL(ts.total,   0) AS task_total,
                IFNULL(ts.done,    0) AS task_done,
                IFNULL(ts.overdue, 0) AS task_overdue

            FROM pacijenti p
            JOIN krevet_detalji kd
                ON kd.id_pacijenta = p.id
                AND (kd.datum_do IS NULL OR kd.datum_do > NOW())
            JOIN krevet k ON k.id = kd.id_kreveta
            JOIN soba   s ON s.id = k.soba_id

            /* --- agregat zadataka po pacijentu za traženi dan --- */
            LEFT JOIN (
                SELECT
                    d.id_pacijenta                 AS pid,
                    COUNT(*)                       AS total,
                    SUM(CASE WHEN d.status = 1 THEN 1 ELSE 0 END) AS done,
                    /* overdue: ako je dan u prošlosti -> sve nezavršeno je overdue;
                    ako je dan danas -> nezavršeno sa vremenom < NOW();
                    ako je u budućnosti -> 0 */
                    SUM(
                        CASE
                        WHEN d.status <> 1 AND (
                            DATE(d.datum) < <cfqueryparam value="#dt#" cfsqltype="cf_sql_date">
                            OR (DATE(d.datum) = <cfqueryparam value="#dt#" cfsqltype="cf_sql_date"> AND TIME(d.datum) < TIME(NOW()))
                        )
                        THEN 1 ELSE 0
                        END
                    ) AS overdue
                FROM ttd_lista_sadrzaj_detalji d
                WHERE d.obrisano = 0
                AND DATE(d.datum) = <cfqueryparam value="#dt#" cfsqltype="cf_sql_date">
                GROUP BY d.id_pacijenta
            ) ts ON ts.pid = p.id

            WHERE 1=1
            <cfif structKeyExists(arguments, "soba_id") AND len(arguments.soba_id)>
                AND s.id = <cfqueryparam value="#arguments.soba_id#" cfsqltype="cf_sql_integer">
            </cfif>

            ORDER BY s.naziv, k.broj_kreveta, p.prezime, p.ime
        </cfquery>

        <cfreturn QueryToArray(q)>
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

</cfcomponent>
