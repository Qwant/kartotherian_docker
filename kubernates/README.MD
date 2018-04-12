#commands
>kubectl exec -it pbfs --container=populate-postgres sh


load_db.pod 
 - pbfpod (download pbf)
 - populate-postgres (start load_db script)
 
 these two containers shares pbfs volume located (/tmp/pbfs)
 
 postgres.rc
  - replicate {one} postgres pod (should be a static set or whatever)
 
 postgres.service
  - serve postgres as a service
  
  
## TODO
 - start load db ""job""
 