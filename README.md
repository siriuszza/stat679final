# stat679final
This is a project using (\textcolor{blue}{sdss/dr17})[https://skyserver.sdss.org/dr17/] data to do classification based on image and sepctra info.

Using SQL to get metadata:

```
SELECT TOP 100000
p.objid,p.ra,p.dec,p.u,p.g,p.r,p.i,p.z,
p.run, p.rerun, p.camcol, p.field,
s.specobjid, s.class, s.z as redshift,
s.plate, s.mjd, s.fiberid,s.plateid
FROM PhotoObj AS p
JOIN SpecObj AS s ON s.bestobjid = p.objid
WHERE 
  p.u BETWEEN 0 AND 19.6
  AND g BETWEEN 0 AND 20
```
