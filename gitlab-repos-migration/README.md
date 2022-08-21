# gitlab-migration
- This Script is used two migrate repos between diffrent gitlab systems 

## Gitlab groups API 
- To get the info about gitlab structure (groups ,subgroups and projects) ,  the gitlab API can be used
The parent group Group ID for example : 123456 
And to get the info about this Group , just call the following API Request 

```
https://gitlab_url/api/v4/groups/123456

```

- To list all subgroups for this parent group 
https://gitlab_url/api/v4/groups/123456/subgroups

- From this info we can get all projects/subgroups under each group usin this API request

```
https://gitlab_url/api/v4/groups/45678/subgroups
https://gitlab_url/api/v4/groups/45678/projects

```

One Case that is diffrent when one of the groups contains multiple pages of projects "pagination" , then we used the following 

```
https://gitlab_url/api/v4/groups/123456/projects?per_page=999
```
then you can extract all info and convert json to csv using any "JSON to CSV" conversion tool 

## Gitlab Export/import API
We used the Gitlab API to export the projects from source gitlab to target gitlab 
# Initiating export request 
```
  https://gitlab_url/api/v4/projects/$id/export
```
# Download the exported project
```
https://gitlab_url/api/v4/projects/${id}/export/download
```
# Importing to the target 
```
https://gitlab_url/api/v4/projects/import
```
# Usage 
Manadatory before running the script
- Two tokens for the SOURCE and Destination gitlab 
- run dos2unix gitlab_repos.csv in case you run the script from windows
```
./repos_migration.sh identifier 
```
for example : exporing all projects with the same identifier identifier_arg_06012020  and importing them to group mentioned on the CSV for example microservices

```
./eport_repos.sh identifier_arg_06012020 
```


The CSV consists of five columns [project ID, current Name, New Name, Identifier , target_namespace ] , So the developer should do the following 
- Open csv and adapt the Identifier or the fourth coulmn from the CSV to be like [identifier_arg_06012020], identifer is used if you want to run the migration of repos bulk by bulk , if you want migrate all in one shot make the same identifier for all 
- Adapt the third colum (The new name for the repo when being imported ).
- In case no changes in the name of the project so  make it like the second column (third column musn't be null)

# Support 
- Walid Ayada - walid.ayada@ibm.com


