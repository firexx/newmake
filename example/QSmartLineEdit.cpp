#include "QSmartLineEdit.h"

bool QSmartLineEdit::validate(QString text)
{
    bool isValid = re.exactMatch(text);

    QRegExpValidator validator(re, this);

    int cursPosition = this->cursorPosition();

    switch (validator.validate(text, cursPosition))
    {
    case QValidator::Invalid:
        this->setStyleSheet("background-color: rgb(255, 192, 192);");
        isValid = false;
        break;
    case QValidator::Intermediate:
        this->setStyleSheet("background-color: rgb(255, 235, 191);");
        isValid = false;
        break;
    case QValidator::Acceptable:
        isValid = true;
        this->setStyleSheet("background-color: rgb(192, 255, 192);");
        break;
    }

    return isValid;
}

bool QSmartLineEdit::isValid()
{
    return validate(this->text());
}

QSmartLineEdit::QSmartLineEdit(QWidget *parent, const QString &regexp_string /*= QString()*/) :QLineEdit(parent), d(), re(regexp_string)
{
    connect(this, SIGNAL(textChanged(QString)), this, SLOT(validate(QString)));
}

QSmartLineEdit::~QSmartLineEdit()
{

}

void QSmartLineEdit::setData(const QVariant &_data)
{
    d = _data;
}

QVariant QSmartLineEdit::data()
{
    return d;
}

void QSmartLineEdit::setValidationString(const QString &string)
{
    re = QRegExp(string);
    validate(this->text());
}
