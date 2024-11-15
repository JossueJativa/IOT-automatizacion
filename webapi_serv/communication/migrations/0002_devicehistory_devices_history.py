# Generated by Django 5.1.3 on 2024-11-12 17:43

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('communication', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='DeviceHistory',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('state', models.BooleanField()),
                ('date', models.DateTimeField(auto_now_add=True)),
            ],
        ),
        migrations.AddField(
            model_name='devices',
            name='history',
            field=models.ManyToManyField(blank=True, null=True, to='communication.devicehistory'),
        ),
    ]
