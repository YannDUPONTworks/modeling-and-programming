SELECT 
	count(distinct g.numero_contrat) nombre_contrat,
	g.entite, 
	g.code_sicovam, 
	g.libelle_du_fonds libelle_fonds, 
	g.type_fonds, 
	g.deffet, 
	sum(g.valeur_acquise_en_euros) encours_fonds, 
	gl.code_isin, 
	ts.libelle libelle_titre,
	gl.equivalent_en_euro encours_titre, 
	ts.categorie_cic,
	ts.type_titre
FROM
	publication.garantie g, 
	publication.globale gl, 
	publication.table_supports_identiques tsi, 
	publication.table_supports ts, 
	( 
	SELECT *
	FROM
		(
		SELECT 
			a.deffet,
			t.categorie_stat,
			a.numero_de_contrat,
			t.nom_apporteur,
			t.nom_stat,
			t.code_apporteur,
			ROW_NUMBER() OVER (PARTITION BY a.numero_de_contrat, a.deffet ORDER BY DECODE(rang_apporteur,'principal',1,'secondaire',2,3)) cpt
		FROM
			publication.apporteurs a,
			publication.table_apporteurs t
		WHERE
			a.inspecteur = t.code_apporteur (+)
		)
	WHERE
		cpt = 1
		AND code_apporteur = '677'
	) a
WHERE
	g.deffet = '31/10/2023'
	AND g.nombre_uc <> 0
	AND g.entite <> 'NAP'
	AND g.type_fonds IN ('FC', 'FD', 'FS')
	AND g.numero_contrat = a.numero_de_contrat
	AND g.deffet = a.deffet
	AND g.code_sicovam = gl.code_sicovam(+)
	AND g.deffet = gl.date_valori_posgloportfeul(+)
	AND gl.code_titre_nl = tsi.code_titre_nl(+)
	AND tsi.reference_titre = ts.reference_titre(+)
GROUP BY 
	g.entite, 
	g.code_sicovam, 
	g.libelle_du_fonds, 
	g.type_fonds, 
	g.deffet, 
	gl.code_isin, 
	ts.libelle,
	gl.equivalent_en_euro, 
	ts.categorie_cic,
	ts.type_titre
ORDER BY 
	g.code_sicovam, 
	gl.code_isin