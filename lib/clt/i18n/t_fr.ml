open T_token

let _t = function
  | Breadcrumb -> "Fil d'ariane"
  | Cancel -> "Annuler"
  | Clear -> "Effacer"
  | Copy -> "Copier"
  | Copy_it_as_a_new_file_with_an_other_name -> "Le copier en tant que nouveau fichier ou répertoire sous un nom différent"
  | Copy_paste -> "Copier & coller"
  | Copy_selection -> "Copier la sélection"
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
  | Delete_selection -> "Supprimer la sélection"
  | Directory_created dirname ->
    Printf.sprintf "Répertoire %s créé" dirname
  | Directory_deleted dirname ->
    Printf.sprintf "Répertoire %s supprimé" dirname
  | Directory_renamed_old_new (oldname, newname) ->
    Printf.sprintf "Répertoire renommé de %s vers %s" oldname newname
  | Download -> "Télécharger"
  | Download_selection -> "Télécharger la sélection"
  | File_deleted filename ->
    Printf.sprintf "Fichier %s supprimé" filename
  | File_renamed_old_new (oldname, newname) ->
    Printf.sprintf "Fichier renommé de %s vers %s" oldname newname
  | Home -> "Accueil"
  | I_understand_all_selected_directories_files_definitively_deleted_dot ->
    "Je comprends que tous les répertoires et fichiers sélectionnés seront supprimés définitivement."
  | I_understand_directory_and_content_will_be_permanently_deleted_dot dirname ->
    Printf.sprintf "Je comprends que le répertoire \"%s\" ainsi que l'intégralité de son contenu seront définitivement supprimés." dirname
  | I_understand_file_will_be_permanently_deleted_dot filename ->
    Printf.sprintf "Je comprends que le fichier \"%s\" sera définitivement supprimé." filename
  | Last_modified -> "Dernière modification"
  | Move -> "Déplacer"
  | Move_selection -> "Déplacer la sélection"
  | Name -> "Nom"
  | New_directory -> "Nouveau répertoire"
  | Overwrite_it_and_replace_it_with_the_copy -> "L'écraser et le remplacer par la copie"
  | Rename -> "Renommer"
  | Rename_directory -> "Renommer le répertoire"
  | Rename_directory_old_new (oldname, newname) ->
    Printf.sprintf "Renommer le répertoire %s vers %s" oldname newname
  | Rename_file -> "Renommer le fichier"
  | Rename_file_old_new (oldname, newname) ->
    Printf.sprintf "Renommer le fichier %s vers %s" oldname newname
  | Select_all -> "Tout sélectionner"
  | Select_directory -> "Sélectionner le répertoire"
  | Select_file -> "Sélectionner le fichier"
  | Selection -> "Sélection"
  | Selection_copied -> "Sélection copiée"
  | Selection_deleted -> "Sélection supprimée"
  | Selection_moved -> "Sélection déplacée"
  | Silently_ignore_it_and_keep_it_untouched -> "L'ignorer et ne pas le modifier"
  | Size -> "Taille"
  | Sort_upward -> "Tri croissant"
  | Sort_downward -> "Tri décroissant"
  | Unable_to_copy_selection -> "Impossible de copier la sélection"
  | Unable_to_create_directory dirname ->
    Printf.sprintf "Impossible de créer le répertoire %s" dirname
  | Unable_to_delete_directory dirname ->
    Printf.sprintf "Impossible de supprimer le répertoire %s" dirname
  | Unable_to_delete_file filename ->
    Printf.sprintf "Impossible de supprimer le fichier %s" filename
  | Unable_to_delete_selection -> "Impossible de supprimer la sélection"
  | Unable_to_download_selection -> "Impossible de télécharger la sélection"
  | Unable_to_move_selection -> "Impossible de déplacer la sélection"
  | Unable_to_rename_directory_old_new (oldname, newname) ->
    Printf.sprintf "Impossible de renommer le répertoire %s vers %s" oldname newname
  | Unable_to_rename_file_old_new (oldname, newname) ->
    Printf.sprintf "Impossible de renommer le fichier %s vers %s" oldname newname
  | Upload -> "Envoyer"
  | When_entry_already_exists_colon -> "Lorsqu'un fichier ou un répertoire existe déjà :"