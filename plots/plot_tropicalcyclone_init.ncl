;***********************************************
; plot_tropicalcyclone_init.ncl
;***********************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  

;************************************************
begin

;************************************************
; Input parameters
;************************************************

  datafilename = "../../../tempestmodel/test/dcmip2016/outTropicalCycloneTest/out.0000-01-01-00000.nc"

;************************************************
; Initialize workspace
;************************************************

  wks = gsn_open_wks("eps","plot_tropicalcyclone_init")   

;************************************************
; Plot resources [options]
;************************************************

  res                     = True
 ;res@mpCenterLonF        = 180
  res@cnFillOn            = True       ; color              [default=False]
  res@cnLinesOn           = True       ; draw contour lines [default=True]
  res@lbLabelAutoStride   = True
  res@vpKeepAspect        = True
  res@vpWidthF            = 0.38       ; user specified shape
  res@vpHeightF           = 0.19
  res@gsnSpreadColors     = True       ; use all colors
  res@gsnSpreadColorStart = 2          ; default=2
  res@gsnSpreadColorEnd   = 23        ; final color of "gui-default"
;  res@gsnSpreadColorStart = 2          ; default=2
;  res@gsnSpreadColorEnd   = 11        ; final color of "cosam"

  res@gsnDraw             = False      ; default=True
  res@gsnFrame            = False      ; default=True

  res_p                   = res        ; pressure plot resources
  res_ps                  = res        ; surface pressure plot resources
  res_u                   = res        ; zonal velocity plot resources
  res_pp                  = res        ; zonal velocity pert plot resources
  res_t                   = res        ; temperature plot resources
  res_qv                  = res        ; water vapor plot resources
  res_theta               = res        ; potential temperature plot resources

;************************************************
; Panel plot
;************************************************
  plot = new(6,graphic)
  gsn_merge_colormaps(wks,"gui_default", "BlRe")
;  gsn_merge_colormaps(wks,"cosam", "BlRe")

  datafile = addfile(datafilename, "r")

  lev = datafile->lev

  rho = datafile->Rho
  t = datafile->T
  theta = datafile->Theta
  u = datafile->U

  qv = datafile->RhoQv / rho * 1000.0
  copy_VarCoords(rho, qv)

  p = rho * 287.0 * t / 100.0
  copy_VarCoords(rho, p)

  pp = p(0,:,:,0) - p(0,:,:,180)
  copy_VarCoords(p(0,:,:,0), pp)

  ps = (p(0,0,:,:) * lev(1) - p(0,1,:,:) * lev(0)) / (lev(1) - lev(0))
  copy_VarCoords(rho(0,0,:,:), ps)

  nlon = dimsizes(u(0,0,0,:))
  up = u
  do i=0,nlon-1
    up(0,0,:,i) = up(0,0,:,i) - u(0,0,:,0)
  end do

; ---
  z = lev * 30.0
  p&lev = z
  t&lev = z
  theta&lev = z
  qv&lev = z
  u&lev = z
  pp&lev = z

; ---
  res_t@cnLevelSelectionMode= "ManualLevels"
  res_t@cnLevelSpacingF   = 10.
  res_t@cnMinLevelValF    = 200.
  res_t@cnMaxLevelValF    = 310.

  res_t@tiYAxisString     = "Altitude (km)"
  res_t@gsnCenterString   = "Temperature"
  res_t@gsnRightString    = "(K)"
  plot(0) = gsn_csm_contour(wks,t(0,:,:,180),res_t) 

  res_theta@cnLevelSelectionMode= "ExplicitLevels"
  res_theta@cnLevels = (/250., 260., 270., 280., 290., 300., 310., 320., 330., 340., 350., 360., 380., 400., 450., 500., 550., 600., 650., 700./)

  res_theta@tiYAxisString     = "Altitude (km)"
  res_theta@gsnCenterString   = "Potential Temperature"
  res_theta@gsnRightString    = "(K)"
  plot(1) = gsn_csm_contour(wks,theta(0,:,:,180),res_theta)

; ---

  res_u@cnLevelSelectionMode= "ManualLevels"
  res_u@cnLevelSpacingF   = 2.0
  res_u@cnMinLevelValF    = -26.0
  res_u@cnMaxLevelValF    = 26.0

  res_u@trXMinF = 0.
  res_u@trXMaxF = 20.
  res_u@tiYAxisString     = "Altitude (km)"
  res_u@gsnCenterString   = "Zonal velocity"
  res_u@gsnRightString    = "(m/s)"
  plot(2) = gsn_csm_contour(wks,u(0,:,:,0),res_u) 

  res_qv@cnLevelSelectionMode= "ManualLevels"
  res_qv@cnLevelSpacingF   = 2.0
  res_qv@cnMinLevelValF    = 2.0
  res_qv@cnMaxLevelValF    = 18.0

  res_qv@tiYAxisString     = "Altitude (km)"
  res_qv@gsnCenterString   = "Specific Humidity"
  res_qv@gsnRightString    = "(g/kg)"
  plot(3) = gsn_csm_contour(wks,qv(0,:,:,180),res_qv) 

; ---

  res_pp@cnLevelSelectionMode= "ManualLevels"
  res_pp@cnLevelSpacingF   = 1.0
  res_pp@cnMinLevelValF    = -10.0
  res_pp@cnMaxLevelValF    = -1.0

  res_pp@trXMinF = 0.
  res_pp@trXMaxF = 20.

  res_pp@tiYAxisString     = "Altitude (km)"
  res_pp@gsnCenterString   = "Pressure perturbation"
  res_pp@gsnRightString    = "(hPa)"
  plot(4) = gsn_csm_contour(wks,pp(:,:),res_pp) 

 res_p@cnLevelSelectionMode= "ExplicitLevels"
 res_p@cnLevels = (/1.e1, 2.e1, 5.e1, 1.e2, 2.e2, 3.e2, 4.e2, 5.e2, 6.e2, 7.e2, 8.e2, 9.e2, 1.e3/)

  res_p@tiYAxisString     = "Altitude (km)"
  res_p@gsnCenterString   = "Background pressure"
  res_p@gsnRightString    = "(hPa)"
  plot(5) = gsn_csm_contour(wks,p(0,:,:,0),res_p) 

 ; res_ps@cnLevelSelectionMode= "ManualLevels"
 ; res_ps@cnLevelSpacingF   = 10.
 ; res_ps@cnMinLevelValF    = 950.
 ; res_ps@cnMaxLevelValF    = 1050.

 ; res_ps@gsnCenterString   = "Surfae Pressure"
 ; res_ps@gsnRightString    = "(hPa)"
 ; plot(5) = gsn_csm_contour(wks,ps(:,:),res_ps) 

; ---

  pres = True
  pres@gsnFrame = False
  pres@gsnPanelYWhiteSpacePercent = 5
  pres@gsnPanelBottom = 0.1

  gsn_panel(wks,plot,(/3,2/),pres)

  frame(wks)


end
