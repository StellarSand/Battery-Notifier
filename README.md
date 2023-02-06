# Battery-Notifier

Monitor and notify when battery reaches a certain set level on GNU/Linux systems.



## Contents
- [Preview](#preview)
- [Installation](#installation)
- [Available options](#available-options)
- [Usage](#usage)
- [Uninstall](#uninstall)
- [Contributing](#contributing)
- [License](#license)



## Preview
![widget-factory](/images/preview.png?raw=true)



## Installation
**1. Clone this repo:**
```
git clone https://github.com/the-weird-aquarian/Battery-Notifier.git
```

**2. Move into the project directory:**
```
cd Battery-Notifier
```

**3. Give executable permissions to the install script:**
```
chmod +x install.sh
```

**4. Run the install script:**
```
./install.sh
```



## Available options
```
 -h,    --help              Show this help message
 -c,    --charged           Set battery charged percent (default = 80)
 -l,    --low               Set battery low percent (default = 20)
 -s,    --sound             Set custom notification sound
 -r,    --repeat            Repeat notification at set interval (in seconds)
                            Default = 60 seconds, 0 = Notify only once
```



## Usage
```
battery-notify -c 60 -l 40
```

Show notification every 15 seconds
```
battery-notify -r 15
```



## Uninstall
If battery-notify has been installed, you can remove it by:

**1. Clone this repo (if not done already):**
```
git clone https://github.com/the-weird-aquarian/Battery-Notifier.git
```

**2. Move into the project directory:**
```
cd Battery-Notifier
```

**3. Give executable permissions to the uninstall script:**
```
chmod +x uninstall.sh
```

**4. Run the uninstall script:**
```
./uninstall.sh
```



## Contributing
Pull requests can be submitted [here](https://github.com/the-weird-aquarian/Battery-Notifier/pulls). Any contribution to the project will be highly appreciated.



## License
This project is licensed under the terms of [MIT License](https://github.com/the-weird-aquarian/Battery-Notifier/blob/main/LICENSE).