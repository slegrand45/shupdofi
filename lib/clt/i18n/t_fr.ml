open T_token

let _t = function
  | Breadcrumb -> "Fil d'ariane"
  | Cancel -> "Annuler"
  | Clear -> "Effacer"
  | Copy_it_as_a_new_file_with_an_other_name -> "Le copier en tant que nouveau fichier ou répertoire sous un nom différent"
  | Copy_paste -> "Copier & coller"
  | Create -> "Créer"
  | Create_directory dirname ->
    Printf.sprintf "Créer le répertoire %s" dirname
  | Cut_paste -> "Couper & coller"
  | Delete -> "Supprimer"
  | Delete_directory -> "Supprimer le répertoire"
  | Delete_directory_name dirname ->
    Printf.sprintf "Supprimer le répertoire %s" dirname
  | Delete_file -> "Supprimer un fichier"
  | Delete_file_name filename ->
    Printf.sprintf "Supprimer le fichier %s" filename
  | Directory_created dirname ->
    Printf.sprintf "Répertoire %s créé" dirname
  | Directory_deleted dirname ->
    Printf.sprintf "Répertoire %s supprimé" dirname
  | Directory_renamed_old_new (oldname, newname) ->
    Printf.sprintf "Répertoire renommé de %s vers %s" oldname newname
  | Download -> "Télécharger"
  | File_deleted filename ->
    Printf.sprintf "Fichier %s supprimé" filename
  | Home -> "Accueil"
  | I_understand_directory_and_content_will_be_permanently_deleted_dot dirname ->
    Printf.sprintf "Je comprends que le répertoire \"%s\" ainsi que l'intégralité de son contenu seront définitivement supprimés." dirname
  | I_understand_file_will_be_permanently_deleted_dot filename ->
    Printf.sprintf "Je comprends que le fichier \"%s\" sera définitivement supprimé." filename
  | Last_modified -> "Dernière modification"
  | Name -> "Nom"
  | New_directory -> "Nouveau répertoire"
  | Overwrite_it_and_replace_it_with_the_copy -> "L'écraser et le remplacer par la copie"
  | Rename -> "Renommer"
  | Rename_directory -> "Renommer le répertoire"
  | Rename_directory_old_new (oldname, newname) ->
    Printf.sprintf "Renommer le répertoire %s vers %s" oldname newname
  | Select_all -> "Tout sélectionner"
  | Select_directory -> "Sélectionner le répertoire"
  | Select_file -> "Sélectionner le fichier"
  | Selection -> "Sélection"
  | Silently_ignore_it_and_keep_it_untouched -> "L'ignorer et ne pas le modifier"
  | Size -> "Taille"
  | Sort_upward -> "Tri croissant"
  | Sort_downward -> "Tri décroissant"
  | Unable_to_create_directory dirname ->
    Printf.sprintf "Impossible de créer le répertoire %s" dirname
  | Unable_to_delete_directory dirname ->
    Printf.sprintf "Impossible de supprimer le répertoire %s" dirname
  | Unable_to_delete_file filename ->
    Printf.sprintf "Impossible de supprimer le fichier %s" filename
  | Upload -> "Envoyer"
  | When_entry_already_exists_colon -> "Lorsqu'un fichier ou un répertoire existe déjà :"