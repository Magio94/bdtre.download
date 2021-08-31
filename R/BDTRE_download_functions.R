#' Function to get municipality identification codes
#'
#' @param selected_province The variable to input to get the municipality codes. The user can select the municipalities by province putting as input '001' (Torino), '002' (Vercelli), '003' (Novara), '004' (Cuneo), '005' (Asti), '006' (Alessandria), '096' (Biella), '103' (Verbano) or 'All' to save the municipality codes for all the region
#'
#' @return It returns a table with column names divided by: Code province, Code municipality, Municipality name
#' @export
#'
#' @examples
#' get_municipality_codes('001')

get_municipality_codes <- function(selected_province) {

  # download the csv table from the ISTAT website (the link should be permanent)
  data <- read.csv("https://www.istat.it/storage/codici-unita-amministrative/Elenco-comuni-italiani.csv",
                   header=FALSE, stringsAsFactors=FALSE, fileEncoding="latin1", sep = ';')

  # get a new data frame with only the relevant columns
  data_new <- data[, c("V1", "V3", "V5", "V7")]

  # rename the columns of the data frame
  colnames(data_new) <- c("Cod_Reg", "Cod_Prov", "Cod_Mun", "Name_Mun")

  # delete the first row of the data frame
  data_new <- data_new[- 1, ]

  # list of the provinces numbers
  province_code <- unique(data_new$Cod_Prov)

  # get the codes for just the municipalities inside the region of the Geo portal
  piemonte_municipalities <- data_new[which(data_new$Cod_Reg=='01'), ]
  piemonte_municipalities$Cod_Reg <- NULL

  if (selected_province %in% province_code) {

    # select the municipality codes by province
    piemonte_municipalities <- piemonte_municipalities[which(piemonte_municipalities$Cod_Prov == selected_province), ]

  } else if (selected_province == "All") {

    # select all the provinces
    piemonte_municipalities = piemonte_municipalities

  } else {
    print("Please select a correct value from: '001', '002', '003', '004', '005', '006','096', '103', 'All'")
  }

  return(piemonte_municipalities)
}

#' It helps the user to set a list to input inside the download_municipality function in order to download the desired municipalities
#'
#' @param user_list It should be a vector built buy the user with the municipal codes on which get information
#'
#' @return It returns a data frame similar to the one made by get_municipality_codes function, but just for the selected codes by the user
#' @export
#'
#' @examples
#' user_list <- c('003016', '005008', '006004', '002035')
#' download_selected_mun(user_list)
#' user_list <- download_selected_mun(user_list)

download_selected_mun <- function(user_list) {

  user_selection <- data.frame(user_list)
  colnames(user_selection) <- c("Cod_Mun")

  return(user_selection)
}



#' Function to download BDTRE database for each municipality desired.
#' You can use the get_municipality_codes function to select municipality codes by province or find just the municipality you are interested on
#'
#' @param municipality_number It should be a data frame structured as the one created by the get_municipality_codes function or download_selected_mun function, inputting
#' a series of municipality codes to be downloaded
#'
#' @return It does not return anything inside the code, it is just a download action and it organizes in different folders what has been downloaded
#' @export
#'
#' @examples
#' user_list <- c('003016', '005008', '006004', '002035')
#' download_selected_mun(user_list)
#' user_list <- download_selected_mun(user_list)
#' download_municipality(user_list)

download_municipality <- function(municipality_number) {

  # create a count of the total number ofusethis::proj_get() municipalities to download
  total <- nrow(municipality_number)
  counter <- 1

  #check if the folders already exists
  if (file.exists('Downloaded')){
    print('The "Downloaded" folder already existed')
  } else {
    dir.create("Downloaded")
  }

  if (file.exists(gsub(" ", "", paste('Downloaded/', deparse(substitute(municipality_number)))))){
    print(paste('The', deparse(substitute(municipality_number),' folder already existed')))
  } else {
    dir.create(gsub(" ", "", paste('Downloaded/', deparse(substitute(municipality_number)))))
  }

  # loop to download each municipality in the data frame
  for (i in municipality_number$Cod_Mun){

    # print the number of municipalities downloaded
    print(paste("Downloaded", counter, "municipalities of", total))

    # add one to the counter so the user know at which municipality the program is.
    counter = counter + 1

    # get the url for each number
    url <- gsub(" ", "", paste('http://www.datigeo-piem-download.it/static/regp01/BDTRE2021_VECTOR/BDTRE_DATABASE_GEOTOPOGRAFICO_2021-LIMI_COMUNI_10_GAIMSDWL-',i,'-EPSG32632-SHP.zip'))

    # create the folder for each number
    dir <- gsub(" ", "", paste(i, '.zip'))

    # download and unzip the data for the number
    download.file(url, dir, mode="wb")
    unzip(dir, exdir = gsub(" ", "", paste('Downloaded/', deparse(substitute(municipality_number)), "/", i)))

    # delete the zip file after unzip to the folder
    file.remove(dir)

  }
}



#' Function for connecting each shape file inside the downloaded folders.
#' This function is the core of the package and is used to read each file downloaded using the download_municipality function.
#' In order to be read, the shape file must in fact be inserted in a path
#'
#' @param chosen_shp The user must enter in this field a selection as a string among the possible ones which are:
#' 'lim_com', 'limi_comuni_piem', 'sed_amm', 'ab_cda_vert', 'el_idr_vert', 'nd_idr', 'af_acq',
#' 'dre_sup', 'ghi_nv', 'invaded_vert', 'sp_acq', 'aatt', 'attr_sp', 'cr_edf', 'cs_edi',
#' 'edi_min', 'ele_cp', 'un_vol', 'embankment', 'dam', 'edifc', 'galler', 'man_tr', 'mn_arr',
#' 'mn_int', 'mn_ind', 'mn_mau', 'mu_sos', 'bridge', 'tralic', 'acc_int'
#' 'acc_pc_civico_tp_str', 'es_amm', 'tp_str', 'cv_liv_class', 'f_nter', 'pt_quo', 'a_tras',
#' 'riverbed', 'alveo_a', 'pe_uins', 'cv_aes', 'cv_dis', 'loc_sg', 'scr_cr',
#' 'ar_vrd', 'bosco', 'cl_agr', 'for_pc', 'ps_inc', 'a_pveg', 'tree', 'fil_al', 'for_pc',
#' 'ac_vei', 'ar_vms', 'el_str_tp_str', 'el_vms', 'gz_str', 'gz_vms', 'iz_str', 'tr_str',
#' 'ac_cic', 'ac_ped', 'el_fer', 'gz_fer', 'sd_fer', 'nd_ele', 'tr_ele', 'v_rete'.
#'
#' It is possible to view the jupyter notebook file for the meaning of each.
#'
#' @return path_shp
#'
#' @export
#'
#' @examples
#' paths <- selection_path('limi_comuni_piem')
#' # or you can simple see the paths
#' selection_path('limi_comuni_piem')

selection_path <- function(chosen_shp) {

  # get the all the paths inside the folder where the program unzipped the files and insert them into a list
  list_dirs <- list.dirs(path = "Downloaded", full.names = TRUE, recursive = TRUE)

  # create different lists by filtering the path by type
  AMM_list <- grep("AMM", list_dirs, value = TRUE, fixed = TRUE)
  IDRO_list <- grep("IDRO", list_dirs, value = TRUE, fixed = TRUE)
  IMM_list <- grep("IMM", list_dirs, value = TRUE, fixed = TRUE)
  IND_list <- grep("IND", list_dirs, value = TRUE, fixed = TRUE)
  ORO_list <- grep("ORO", list_dirs, value = TRUE, fixed = TRUE)
  PERT_list <- grep("PERT", list_dirs, value = TRUE, fixed = TRUE)
  TOPO_list <- grep("TOPO", list_dirs, value = TRUE, fixed = TRUE)
  VEG_list <- grep("VEG", list_dirs, value = TRUE, fixed = TRUE)
  VIAB_list <- grep("VIAB", list_dirs, value = TRUE, fixed = TRUE)
  SERV_list <- grep("SERV", list_dirs, value = TRUE, fixed = TRUE)
  GEOFOTO_list <- grep("GEOFOTO", list_dirs, value = TRUE, fixed = TRUE)

  # create the lists for the last part of each path connected to the shapefiles
  AMM_selection <- list('/lim_com_2021.shp', '/limi_comuni_piem_2021.shp', '/sed_amm_2021.shp')
  IDRO_selection <- list('/ab_cda_vert_2021.shp', '/el_idr_vert_2021.shp', '/nd_idr_2021.shp',
                         '/af_acq_2021.shp', '/dre_sup_2021.shp', '/ghi_nv_2021.shp', '/invaso_vert_2021.shp',
                         '/sp_acq_vert_2021.sh')
  IMM_selection <- list('/aatt_2021.shp', '/attr_sp_2021.shp', '/cr_edf_2021.shp', '/cs_edi_2021.shp',
                        '/edi_min_2021.shp', '/ele_cp_2021.shp', '/un_vol_2021.shp', '/argine_2021.shp',
                        '/diga_2021.shp', '/edifc_2021.shp', '/galler_2021.shp', '/man_tr_2021.shp',
                        '/mn_arr_2021.shp', '/mn_int_2021.shp', '/mn_ind_2021.shp', '/mn_mau_2021.shp',
                        '/mu_sos_2021.shp', '/ponte_2021.shp', '/tralic_2021.shp')
  IND_selection <- list('/acc_int_2021.shp', '/acc_pc_civico_tp_str_2021.shp', '/es_amm_2021.shp',
                        '/tp_str_2021.shp')
  ORO_selection <- list('/cv_liv_class_2021.shp', '/f_nter_2021.shp', '/pt_quo_2021.shp', '/a_tras_2021.shp',
                        '/alveo_2021.shp', '/alveo_a_2021.shp')
  PERT_selection <- list('/pe_uins_2021.shp', '/cv_aes_2021.shp', '/cv_dis_2021.shp')
  TOPO_selection <- list('/loc_sg_2021.shp', '/scr_cr_2021.shp')
  VEG_selection <- list('/ar_vrd_2021.shp', '/bosco_2021.shp', '/cl_agr_2021.shp', '/for_pc_2021.shp',
                        '/ps_inc_2021.shp', '/a_pveg_2021.shp', '/albero_2021.shp', '/fil_al_2021.shp',
                        '/for_pc_2021.shp')
  VIAB_selection <- list('/ac_vei_2021.shp', '/ar_vms_2021.shp', '/el_str_tp_str_2021.shp', '/el_vms_2021.shp',
                         '/gz_str_2021.shp', '/gz_vms_2021.shp', '/iz_str_2021.shp', '/tr_str_2021.shp',
                         '/ac_cic_2021.shp', '/ac_ped_2021.shp', '/el_fer_2021.shp', '/gz_fer_2021.shp',
                         '/sd_fer_2021.shp')
  SERV_selection <- list('/nd_ele_2021.shp', '/tr_ele_2021.shp')
  GEOFOTO_selection <- list('/v_rete_2021.shp')

  # create a list with the possible selections
  selection_list <- c('lim_com', 'limi_comuni_piem', 'sed_amm', 'ab_cda_vert', 'el_idr_vert', 'nd_idr', 'af_acq',
                      'dre_sup', 'ghi_nv', 'invaso_vert', 'sp_acq', 'aatt', 'attr_sp', 'cr_edf', 'cs_edi',
                      'edi_min', 'ele_cp', 'un_vol', 'argine', 'diga', 'edifc', 'galler', 'man_tr', 'mn_arr',
                      'mn_int', 'mn_ind', 'mn_mau', 'mu_sos', 'ponte', 'tralic', 'acc_int',
                      'acc_pc_civico_tp_str', 'es_amm', 'tp_str', 'cv_liv_class', 'f_nter', 'pt_quo', 'a_tras',
                      'alveo', 'alveo_a', 'pe_uins', 'cv_aes', 'cv_dis', 'loc_sg', 'scr_cr',
                      'ar_vrd', 'bosco', 'cl_agr', 'for_pc', 'ps_inc', 'a_pveg', 'albero', 'fil_al', 'for_pc',
                      'ac_vei', 'ar_vms', 'el_str_tp_str', 'el_vms', 'gz_str', 'gz_vms', 'iz_str', 'tr_str',
                      'ac_cic', 'ac_ped', 'el_fer', 'gz_fer', 'sd_fer', 'nd_ele', 'tr_ele', 'v_rete')

  # create the new list where it appends all the complete path for the wanted shape file
  path_shp <- c()

  selected_shp = chosen_shp

  # create the list in base of the selection
  if (selected_shp == 'lim_com') {
    # create the list to open the files in the AMM folder
    for (i in AMM_list) {
      path <- gsub(" ", "", paste(i, AMM_selection[1]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'limi_comuni_piem') {

    for (i in AMM_list) {
      path <- gsub(" ", "", paste(i, AMM_selection[2]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'sed_amm') {
    for (i in AMM_list) {
      path <- gsub(" ", "", paste(i, AMM_selection[3]))
      path_shp <- c(path_shp, path)
    }

    # create the list to open the files in the IDRO folder
  } else if (selected_shp == 'ab_cda_vert') {
    for (i in IDRO_list) {
      path <- gsub(" ", "", paste(i, IDRO_selection[1]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'el_idr_vert') {
    for (i in IDRO_list) {
      path <- gsub(" ", "", paste(i, IDRO_selection[2]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'nd_idr') {

    for (i in IDRO_list) {
      path <- gsub(" ", "", paste(i, IDRO_selection[3]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'af_acq') {
    for (i in IDRO_list) {
      path <- gsub(" ", "", paste(i, IDRO_selection[4]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'dre_sup') {
    for (i in IDRO_list) {
      path <- gsub(" ", "", paste(i, IDRO_selection[5]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'ghi_nv') {
    for (i in IDRO_list) {
      path <- gsub(" ", "", paste(i, IDRO_selection[6]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'invaso_vert') {
    for (i in IDRO_list) {
      path <- gsub(" ", "", paste(i, IDRO_selection[7]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'sp_acq') {
    for (i in IDRO_list) {
      path <- gsub(" ", "", paste(i, IDRO_selection[8]))
      path_shp <- c(path_shp, path)
    }

    # create the list to open the files in the IMM folder
  } else if (selected_shp == 'aatt') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[1]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'attr_sp') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[2]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'cr_edf') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[3]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'cs_edi') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[4]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'edi_min') {

    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[5]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'ele_cp') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[6]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'un_vol') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[7]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'argine') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[8]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'diga') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[9]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'edifc') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[10]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'galler') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[11]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'man_tr') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[12]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'mn_arr') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[13]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'mn_int') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[14]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'mn_ind') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[15]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'mn_mau') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[16]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'mu_sos') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[17]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'ponte') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[18]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'tralic') {
    for (i in IMM_list) {
      path <- gsub(" ", "", paste(i, IMM_selection[19]))
      path_shp <- c(path_shp, path)
    }

    # create the list to open the files in the IND folder
  } else if (selected_shp == 'acc_int') {
    for (i in IND_list) {
      path <- gsub(" ", "", paste(i, IND_selection[1]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'acc_pc_civico_tp_str') {
    for (i in IND_list) {
      path <- gsub(" ", "", paste(i, IND_selection[2]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'es_amm') {
    for (i in IND_list) {
      path <- gsub(" ", "", paste(i, IND_selection[3]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'tp_str') {
    for (i in IND_list) {
      path <- gsub(" ", "", paste(i, IND_selection[4]))
      path_shp <- c(path_shp, path)
    }

    # create the list to open the files in the ORO folder

  } else if (selected_shp == 'cv_liv_class') {
    for (i in ORO_list) {
      path <- gsub(" ", "", paste(i, ORO_selection[1]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'f_nter') {
    for (i in ORO_list) {
      path <- gsub(" ", "", paste(i, ORO_selection[2]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'pt_quo') {
    for (i in ORO_list) {
      path <- gsub(" ", "", paste(i, ORO_selection[3]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'a_tras') {
    for (i in ORO_list) {
      path <- gsub(" ", "", paste(i, ORO_selection[4]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'alveo') {
    for (i in ORO_list) {
      path <- gsub(" ", "", paste(i, ORO_selection[5]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'alveo_a') {
    for (i in ORO_list) {
      path <- gsub(" ", "", paste(i, ORO_selection[6]))
      path_shp <- c(path_shp, path)
    }


    # create the list to open the files in the PERT folder

  } else if (selected_shp == 'pe_uins') {
    for (i in PERT_list) {
      path <- gsub(" ", "", paste(i, PERT_selection[1]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'cv_aes') {
    for (i in PERT_list) {
      path <- gsub(" ", "", paste(i, PERT_selection[2]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'cv_dis') {
    for (i in PERT_list) {
      path <- gsub(" ", "", paste(i, PERT_selection[3]))
      path_shp <- c(path_shp, path)
    }


    # create the list to open the files in the TOPO folder
  } else if (selected_shp == 'loc_sg') {
    for (i in TOPO_list) {
      path <- gsub(" ", "", paste(i, TOPO_selection[1]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'scr_cr') {
    for (i in TOPO_list) {
      path <- gsub(" ", "", paste(i, TOPO_selection[2]))
      path_shp <- c(path_shp, path)
    }

    # create the list to open the files in the VEG folder
  } else if (selected_shp == 'ar_vrd') {
    for (i in VEG_list) {
      path <- gsub(" ", "", paste(i, VEG_selection[1]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'bosco') {
    for (i in VEG_list) {
      path <- gsub(" ", "", paste(i, VEG_selection[2]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'cl_agr') {
    for (i in VEG_list) {
      path <- gsub(" ", "", paste(i, VEG_selection[3]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'for_pc') {
    for (i in VEG_list) {
      path <- gsub(" ", "", paste(i, VEG_selection[4]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'ps_inc') {
    for (i in VEG_list) {
      path <- gsub(" ", "", paste(i, VEG_selection[5]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'a_pveg') {
    for (i in VEG_list) {
      path <- gsub(" ", "", paste(i, VEG_selection[6]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'albero') {
    for (i in VEG_list) {
      path <- gsub(" ", "", paste(i, VEG_selection[7]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'fil_al') {
    for (i in VEG_list) {
      path <- gsub(" ", "", paste(i, VEG_selection[8]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'for_pc') {
    for (i in VEG_list) {
      path <- gsub(" ", "", paste(i, VEG_selection[9]))
      path_shp <- c(path_shp, path)
    }

    # create the list to open the files in the VIAB folder
  } else if (selected_shp == 'ac_vei') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[1]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'ar_vms') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[2]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'el_str_tp_str') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[3]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'el_vms') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[4]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'gz_str') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[5]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'gz_vms') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[6]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'iz_str') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[7]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'tr_str') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[8]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'ac_cic') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[9]))
      path_shp <- c(path_shp, path)
    }


  } else if (selected_shp == 'ac_ped') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[10]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'el_fer') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[11]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'gz_fer') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[12]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'sd_fer') {
    for (i in VIAB_list) {
      path <- gsub(" ", "", paste(i, VIAB_selection[13]))
      path_shp <- c(path_shp, path)
    }

    # create the list to open the files in the SERV folder
  } else if (selected_shp == 'nd_ele') {
    for (i in SERV_list) {
      path <- gsub(" ", "", paste(i, SERV_selection[1]))
      path_shp <- c(path_shp, path)
    }

  } else if (selected_shp == 'tr_ele') {
    for (i in SERV_list) {
      path <- gsub(" ", "", paste(i, SERV_selection[2]))
      path_shp <- c(path_shp, path)
    }

    # create the list to open the files in the GEOFOTO folder
  } else if (selected_shp == 'v_rete') {
    for (i in GEOFOTO_list) {
      path <- gsub(" ", "", paste(i, GEOFOTO_selection[1]))
      path_shp <- c(path_shp, path)
    }

  } else {print('Wrong selection')}

  return(path_shp)
}

#' This function is useful for merging all the shape files for the selected category.
#' It helps the user to make an unique shape file from all the shape files related to one category
#'
#' @param chosen_shp Must be any from selection_list
#'
#' @return nc_merge
#' @export
#'
#' @examples
#' nc_merge <- merging_shp('limi_comuni_piem')
#'
#' @import sf


merging_shp <- function(chosen_shp) {



  path_shp <- selection_path(chosen_shp)

  nc <- st_read(path_shp[1], quiet = TRUE)
  nc2 <- st_read(path_shp[2], quiet = TRUE)
  nc_merge <- rbind(nc, nc2)
  path_shp_clean1 <- path_shp[-1]
  path_shp_clean <- path_shp[-1]

  for (i in path_shp) {
    nc <- st_read(i, quiet = TRUE)
    nc_merge <- rbind(nc, nc_merge)
  }

  return(nc_merge)
}

#' Example of possible uses of the package and downloaded data
#' Calculate urbanization index for each municipalities
#' To do that it keeps all the shape files for the urbanized areas calculating the areas
#' for each of it and summarizing and after make the percent on the total of the municipality surface
#'
#' @param m_codes Must be a data frame such as from get_municipality_codes
#'
#' @return data_frame_data You can return a data frame where the data are stored in different columns:
#' 1) name of the municipalities, 2) ISTAT code and 3) percent of urbanized areas
#'
#' @export
#'
#' @examples
#' Biella_province <- get_municipality_codes("096")
#' download_municipality(Biella_province)
#' data_frame_data <- percent_urbanized(Biella_province)

percent_urbanized <- function(m_codes) {



  # create the vectors that save in the order of the process the name of the municipalities, Istat code and index
  mun_name <- c()
  perc_urb <- c()
  cod_istat <- c()

  # the list of the element indicating urbanization
  urbanized_areas <- c('un_vol', 'sd_fer', 'cv_dis', 'pe_uins', 'mn_ind', 'man_tr', 'ele_cp', 'cv_aes', 'ar_vms',
                       'ac_vei', 'ac_ped', 'aatt')

  # create a list for the interested municipalities of the shape file polygonal boundaries
  mun_borders <- selection_path('limi_comuni_piem')
  list_path_selection <- c()

  # creating a loop to get all the paths for the urbanized_areas vector
  for(i in urbanized_areas) {
    list_path_selection <- c(list_path_selection, selection_path(i))
  }

  # create a vector that saves the path for the municipality processed in the loop
  list_urbanized_shp <- c()

  # for loop to check if the path effectively exists and append the paths
  for (x in list_path_selection) {
    if (file.exists(x)) {
      list_urbanized_shp <- append(list_urbanized_shp, x)
    }}

  # loop to create lists, one with the shape files relative to the urbanized areas
  # and another shape file with the boundary area
  for (y in m_codes$Cod_Mun) {
    name_municipality <- m_codes[which(m_codes$Cod_Mun == y), ]

    # list with all the path to the shape files relative to the urbanized geometries
    selected_municipality <- grep(y, list_urbanized_shp, value = TRUE, fixed = TRUE)

    #select the boundary area of the municipality
    selected_mun_borders <- grep(y, mun_borders, value = TRUE, fixed = TRUE)

    # calculate the area of the municipality surface
    mun_shp <- st_read(selected_mun_borders, quiet = TRUE)
    area_mun <- st_area(mun_shp)

    # read all the shape files for the urbanized area in the list
    urbanized_values <- c()
    for (i in selected_municipality) {
      shp <- st_read(i, quiet = TRUE)
      shp$area <- st_area(shp)
      sum_area <- sum(shp$area)
      urbanized_values <- c(urbanized_values, sum_area)
    }

    # sum all the shape files for the urbanized areas
    total_urbanized <- sum(urbanized_values)
    tot_urb_area <- (total_urbanized/area_mun) * 100

    # create the vectors
    perc_urb <- c(perc_urb, tot_urb_area)
    mun_name<- c(mun_name, name_municipality$Name_Mun)
    cod_istat <- c(cod_istat, name_municipality$Cod_Mun)

    print(paste("The percent of urbanized area for", name_municipality$Name_Mun, "is", gsub(" ", "", paste(tot_urb_area,'%'))))
  }

  data_frame_data <- data.frame(mun_name, cod_istat, perc_urb)
  colnames(data_frame_data) <- c("Name_Mun", "COMUNE_IST", "Perc_urb")

  return(data_frame_data)
}
