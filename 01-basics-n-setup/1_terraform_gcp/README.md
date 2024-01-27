## This part is only for testing. Unset once testing is done and credentials are set via `variables.tf`

- Only For use without variables
```
export GOOGLE_CREDENTIALS='./keys/my-creds.json'
echo $GOOGLE_CREDENTIALS
```

- For use with variables
```
export GOOGLE_CREDENTIALS='../terraform/keys/my-creds.json'
echo $GOOGLE_CREDENTIALS
```

- Unset in the end
```
unset GOOGLE_CREDENTIALS
echo $GOOGLE_CREDENTIALS
```
**Note**: Do **NOT** upload credential files to github to repository or anywhere on internet. This can be done by adding those files/folders to .gitignore

-------------------------------

- Update `.tf` files to terraform format 
```
terraform fmt
```

- Download providers
```
terraform init
```

- See tha plan
 ```
 terraform plan
 ```

- apply the plan to create infra
```
terraform apply
yes
```

- Destroy the infra
```
terraform destroy
yes
```