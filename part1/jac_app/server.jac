walker interact {
    can return_message with `root entry {
        report {
            "response": "Hello, world!"
        };
    }
}

walker interact_with_body {
    has name: str;

    can return_message with `root entry {
        report {
            "response": "Hello, " + self.name + "!"
        };
    }
}

# New walker 1: return num1 - num2
walker subtract_numbers {
    has num1: int;
    has num2: int;
    can return_message with `root entry {
        report {
            "difference": self.num1 - self.num2
        };
    }

}

walker multiply_numbers {
    has num1: int;
    has num2: int;
    can return_message with `root entry {
        report {
            'product': self.num1 * self.num2
        };
    }

}
