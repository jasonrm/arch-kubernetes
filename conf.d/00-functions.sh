# Global Functions

function ipfor() {
  ping -c 1 $1 | grep -Eo -m 1 '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}';
}
