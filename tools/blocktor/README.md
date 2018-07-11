# blocktor
## Block all Tor Network from accessing your webserver
> Need ipset:
```
apt-get install -y ipset
```
> Usage
```
chmod +x blocktor.sh
sudo ./blocktor.sh --start
sudo ./blocktor.sh --stop
```
> Add to root crontab (sudo crontab -e):
```
@reboot /path/to/blocktor.sh --start
0 0 * * * /path/to/blocktor.sh --start
```
### Donate!
Support the authors:

<noscript><a href="https://liberapay.com/thelinuxchoice/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a></noscript>
