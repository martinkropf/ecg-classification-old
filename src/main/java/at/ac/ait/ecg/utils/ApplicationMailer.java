package at.ac.ait.ecg.utils;

import javax.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.mail.javamail.MimeMessagePreparator;
import org.springframework.stereotype.Service;

@Service("mailService")
public class ApplicationMailer {

	@Autowired
	private JavaMailSender mailSender;

	@Value("${mail.from}")
	String mailFrom;

	@Value("${mail.to}")
	String mailTo;

	@Value("${app.url}")
	String baseUrl;

	/**
	 * This method will send the review notification
	 * */
	public void sendReviewMail(final String pseudonym) {
		final StringBuilder sb = new StringBuilder();
		sb.append("A new treatment plan has been uploaded for ");
		sb.append(pseudonym);
		sb.append("<br/>");
		sb.append("<a href='" + baseUrl + "prospective_review/" + pseudonym + "' >Review treatment plan</a>");

		MimeMessagePreparator preparator = new MimeMessagePreparator() {
			public void prepare(MimeMessage mimeMessage) throws Exception {
				MimeMessageHelper message = new MimeMessageHelper(mimeMessage);
				message.setFrom(mailFrom);
				message.setTo(mailTo);
				message.setSubject("Treatment plan uploaded for: " + pseudonym);
				message.setText(sb.toString(), true);
			}
		};
		mailSender.send(preparator);
	}

	/**
	 * This method will send the finished notification
	 * */
	public void sendFinishedMail(final String pseudonym) {
		final StringBuilder sb = new StringBuilder();
		sb.append("The uploaded treatment plan has been reviewed for ");
		sb.append(pseudonym);
		sb.append("<br/>");
		sb.append("<a href='" + baseUrl + "prospective_review/" + pseudonym + "' >Open review</a>");

		MimeMessagePreparator preparator = new MimeMessagePreparator() {
			public void prepare(MimeMessage mimeMessage) throws Exception {
				MimeMessageHelper message = new MimeMessageHelper(mimeMessage);
				message.setFrom(mailFrom);
				message.setTo(mailTo);
				message.setSubject("Treatment plan reviewed for: " + pseudonym);
				message.setText(sb.toString(), true);
			}
		};
		mailSender.send(preparator);
	}
}