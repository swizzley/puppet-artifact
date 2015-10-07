#swizzley88-artifact release

Below an overview of all changes in the releases.

Version (Release date)

0.3.0   (2015-10-07)

  * deprecated legacy param

0.2.8   (2015-10-07)

  * moved file declare outside of legacy

0.2.7   (2015-10-07)

  * simplified manifests for packages and script
  * set package and file require parameters to avoid catalog compilation mismatch
  * added owner/group/mode params
  * improved legacy rename
  * removed resume download functionality, could cause corruption for volitile artifacts whos download is interrupted

0.2.6   (2015-10-06)

  * added dependant packages to module
  * fixed logic in script to avoid re-downloading
  * improved error messages
  * added resume download functionality 

0.2.5   (2015-10-06)

  * actually fixed duplicate declaration for script
  * removed $bin_dir param

0.2.4   (2015-10-06)

  * fixed duplicate declaration for script

0.2.3   (2015-10-06)

  * readme fix

0.2.2   (2015-10-06)

  * fixed swap size = 0 issue after downloading fresh
  * removed ensure dir for /usr/local/sbin
  * added param for /usr/local/sbin $bin_dir
  * added params to readme

0.2.1   (2015-10-05)

  * fixed timeout param

0.2.0   (2015-10-05)

  * Added Legacy param [default: false]
  * Added more efficient way to update artifacts based on file size, required [dos2unix]
  
0.1.4   (2015-09-18)

  * Added timeout param, [default: 0]
