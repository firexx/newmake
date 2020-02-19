#ifndef QSMARTLINEEDIT_H
#define QSMARTLINEEDIT_H

#include <QLineEdit>
#include <QRegExpValidator>

class QSmartLineEdit : public QLineEdit {
    Q_OBJECT
  public slots:
    bool validate( QString text );;
  public:

    bool isValid();

    QSmartLineEdit( QWidget* parent, const QString& regexp_string = QString() );

    virtual ~QSmartLineEdit();
    virtual void setData( const QVariant& _data );
    virtual QVariant data();
    void setValidationString( const QString& string );
  protected:
    QVariant d;
    QRegExp re;
};

#endif // QSMARTLINEEDIT_H
