

function generateElement(element, attrs) {
    console.log(`Processing '${element}' with attributes '${Object.keys(attrs)}'`);

    styles = '';
    Object.keys(attrs).forEach(property => {
        if (styles.length > 0) {
            styles += ' ';
        }
        styles += `${property}: ${attrs[property]};`
    });

    return `<${element} style="${styles}">
    This is a ${element}
</${element}>`;
}

module.exports = function (registry) {
    registry.blockMacro(function () {
        let self = this;
        self.named('htmlElement');
        self.process(function (parent, target, attrs) {

            return self.createBlock(parent, 'pass', generateElement(target, attrs));
        })
    })
}